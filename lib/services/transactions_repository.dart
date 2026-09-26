import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_traq/app/currencies.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/monthly_total.dart';
import 'package:monthly_traq/models/transaction_model.dart';

/// Thrown when a Firestore write doesn't get an ack within [_writeTimeout] —
/// almost always because the device is offline. The write itself is NOT
/// cancelled: Firestore's own offline queue still holds it and will sync it
/// once connectivity returns, so this just stops the UI from waiting
/// forever with no feedback.
class SyncTimeoutException implements Exception {
  @override
  String toString() =>
      "No internet connection. This will be saved automatically once you're back online.";
}

const _writeTimeout = Duration(seconds: 10);

const _defaultSeedCategories = [
  (name: 'Shopping', iconKey: 'shopping_bag'),
  (name: 'Food', iconKey: 'restaurant'),
  (name: 'Phone', iconKey: 'smartphone'),
  (name: 'Entertainment', iconKey: 'movie'),
  (name: 'Education', iconKey: 'school'),
  (name: 'Beauty', iconKey: 'content_cut'),
  (name: 'Sports', iconKey: 'directions_run'),
  (name: 'Social', iconKey: 'people'),
  (name: 'Transportation', iconKey: 'directions_bus'),
  (name: 'Clothing', iconKey: 'checkroom'),
  (name: 'Car', iconKey: 'directions_car'),
  (name: 'Alcohol', iconKey: 'wine_bar'),
  (name: 'Cigarettes', iconKey: 'smoking_rooms'),
  (name: 'Electronics', iconKey: 'computer'),
  (name: 'Travel', iconKey: 'flight'),
  (name: 'Health', iconKey: 'favorite'),
  (name: 'Pets', iconKey: 'pets'),
  (name: 'Repairs', iconKey: 'build'),
  (name: 'Housing', iconKey: 'house'),
  (name: 'Home', iconKey: 'weekend'),
  (name: 'Gifts', iconKey: 'card_giftcard'),
  (name: 'Donations', iconKey: 'volunteer_activism'),
  (name: 'Lottery', iconKey: 'casino'),
  (name: 'Snacks', iconKey: 'cookie'),
  (name: 'Kids', iconKey: 'child_care'),
  (name: 'Vegetables', iconKey: 'eco'),
  (name: 'Fruits', iconKey: 'shopping_basket'),
];

const _defaultIncomeSeedCategories = [
  (name: 'Salary', iconKey: 'work'),
  (name: 'Investments', iconKey: 'trending_up'),
  (name: 'Part-Time', iconKey: 'handshake'),
  (name: 'Bonus', iconKey: 'emoji_events'),
  (name: 'Others', iconKey: 'paid'),
];

/// Holds transactions, categories and the monthly budget for the signed-in
/// user, mirrored live from that user's Firestore subtree
/// (`users/{uid}/transactions`, `users/{uid}/categories`,
/// `users/{uid}.monthlyBudget`). Recreates its subscriptions whenever the
/// signed-in user changes, and clears its local cache on sign-out.
class TransactionsRepository extends ChangeNotifier {
  TransactionsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _categoriesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _transactionsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  List<CategoryModel> _categories = [];
  List<TransactionModel> _transactions = [];
  double monthlyBudget = 60000;
  // Which day of the calendar month the budget cycle resets on — lets a
  // user whose salary lands on, say, the 25th track "this month" against
  // their own pay cycle instead of the 1st.
  int monthStartDay = 1;
  String currencySymbol = 'Rs.';
  // Null for symbols set before the full currency picker existed, or a
  // custom symbol that doesn't match any listed currency — the Settings
  // row falls back to showing just the symbol in that case.
  String? currencyCode;
  // A small compressed profile photo, base64-encoded directly into the
  // user doc rather than Firebase Storage — Storage requires the paid
  // Blaze plan just to be enabled at all, even for zero-cost usage.
  String? photoBase64;
  bool isLoading = true;

  /// True while the most recent categories snapshot was served from local
  /// cache rather than confirmed by the server — the app's best signal for
  /// "you're offline (or a write is still in flight)".
  bool isOffline = false;

  Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(
      _writeTimeout,
      onTimeout: () => throw SyncTimeoutException(),
    );
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  void _onAuthChanged(User? user) {
    _categoriesSub?.cancel();
    _transactionsSub?.cancel();
    _userDocSub?.cancel();

    if (user == null) {
      _categories = [];
      _transactions = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    final userDoc = _firestore.collection('users').doc(user.uid);

    _userDocSub = userDoc.snapshots().listen((snap) {
      final data = snap.data();
      final budget = data?['monthlyBudget'];
      if (budget is num) monthlyBudget = budget.toDouble();
      final startDay = data?['monthStartDay'];
      if (startDay is int && startDay >= 1 && startDay <= 31) {
        monthStartDay = startDay;
      }
      final currency = data?['currencySymbol'];
      if (currency is String && currency.isNotEmpty) currencySymbol = currency;
      final code = data?['currencyCode'];
      currencyCode = code is String && code.isNotEmpty ? code : null;
      final photo = data?['photoBase64'];
      photoBase64 = photo is String && photo.isNotEmpty ? photo : null;
      notifyListeners();
    });

    _cycleOffset = 0;
    _colorMigrationChecked = false;

    _categoriesSub = userDoc
        .collection('categories')
        .orderBy('createdAt')
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
          if (!snap.metadata.isFromCache) _migrateCategoryColors(snap.docs);
          _categories = _sortCategories(
            snap.docs.map(CategoryModel.fromDoc).toList(),
          );
          isLoading = false;
          isOffline = snap.metadata.isFromCache;
          notifyListeners();
        });

    _transactionsSub = userDoc
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
          _transactions = snap.docs.map(TransactionModel.fromDoc).toList();
          notifyListeners();
        });
  }

  static Color _paletteSlot(int index) =>
      AppPalette.categorical[index % AppPalette.categorical.length];

  bool _colorMigrationChecked = false;

  /// One-time recolor onto the current palette. Categories store their
  /// color, so accounts created before the 12-color palette still carry the
  /// old 8 (including the green and red slots that clashed with
  /// income/expense). If any stored color isn't in today's palette, every
  /// category is reassigned a slot by creation order, counted per type —
  /// the same assignment a fresh account gets. Checked once per sign-in, on
  /// the first server-confirmed snapshot (a cached one may be partial); a
  /// failed write simply retries next session.
  void _migrateCategoryColors(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (_colorMigrationChecked || docs.isEmpty) return;
    _colorMigrationChecked = true;

    final current = {for (final c in AppPalette.categorical) c.toARGB32()};
    if (docs.every((d) => current.contains(d.data()['color']))) return;

    final batch = _firestore.batch();
    final perType = <String, int>{};
    for (final doc in docs) {
      final type = doc.data()['type'] == 'income' ? 'income' : 'expense';
      final index = perType[type] ?? 0;
      perType[type] = index + 1;
      batch.update(doc.reference, {'color': _paletteSlot(index).toARGB32()});
    }
    unawaited(batch.commit().catchError((Object _) {}));
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _categoriesSub?.cancel();
    _transactionsSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }

  /// Categories with an explicit `sortOrder` (from a manual reorder or a
  /// fresh add) come first, sorted by that value; categories from before
  /// reordering existed keep their original (createdAt query) order,
  /// placed after all the explicitly-ordered ones.
  List<CategoryModel> _sortCategories(List<CategoryModel> categories) {
    final indexed = categories.indexed.toList();
    indexed.sort((a, b) {
      final aOrder = a.$2.sortOrder;
      final bOrder = b.$2.sortOrder;
      if (aOrder != null && bOrder != null) return aOrder.compareTo(bOrder);
      if (aOrder != null) return -1;
      if (bOrder != null) return 1;
      return a.$1.compareTo(b.$1);
    });
    return [for (final entry in indexed) entry.$2];
  }

  CategoryModel? categoryById(String? id) {
    if (id == null) return null;
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  // All-time totals — used only for `balance`, your overall net worth.
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (total, t) => total + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (total, t) => total + t.amount);

  double get balance => totalIncome - totalExpense;

  /// [day] clamped to however many days [year]-[month] actually has (so a
  /// start day of 31 falls back to the 28th/29th/30th in shorter months).
  DateTime _cycleDate(int year, int month, int day) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, daysInMonth));
  }

  DateTime get _currentCycleStart {
    final now = DateTime.now();
    final startThisMonth = _cycleDate(now.year, now.month, monthStartDay);
    if (!now.isBefore(startThisMonth)) return startThisMonth;
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    return _cycleDate(prevYear, prevMonth, monthStartDay);
  }

  /// The start of the cycle [offset] cycles away from the current one
  /// (0 = current, -1 = the one before, ...).
  DateTime _cycleStartAt(int offset) {
    final current = _currentCycleStart;
    // DateTime normalizes an out-of-range month (e.g. 0 or 13) into the
    // neighbouring year, so plain month arithmetic is safe here.
    final target = DateTime(current.year, current.month + offset);
    return _cycleDate(target.year, target.month, monthStartDay);
  }

  // Which budget cycle Transactions and Analytics are showing, relative to
  // the current one — shared here so both tabs always show the same month.
  int _cycleOffset = 0;

  bool get isCurrentCycle => _cycleOffset == 0;

  void showPreviousCycle() {
    _cycleOffset--;
    notifyListeners();
  }

  void showNextCycle() {
    if (_cycleOffset >= 0) return;
    _cycleOffset++;
    notifyListeners();
  }

  void showCurrentCycle() {
    if (_cycleOffset == 0) return;
    _cycleOffset = 0;
    notifyListeners();
  }

  DateTime get _selectedCycleStart => _cycleStartAt(_cycleOffset);
  DateTime get _selectedCycleEnd => _cycleStartAt(_cycleOffset + 1);

  bool _isInSelectedCycle(DateTime date) {
    return !date.isBefore(_selectedCycleStart) &&
        date.isBefore(_selectedCycleEnd);
  }

  bool _isInCurrentCycle(DateTime date) {
    return !date.isBefore(_cycleStartAt(0)) && date.isBefore(_cycleStartAt(1));
  }

  /// "September" when the cycle starts on the 1st (matching the calendar
  /// month), or a "Sep 25 – Oct 24"-style range once the user has picked a
  /// custom start day, so the label never implies a plain calendar month it
  /// doesn't actually track. Adds the year for cycles outside this year.
  String _labelForCycle(int offset) {
    final start = _cycleStartAt(offset);
    final showYear = start.year != DateTime.now().year;
    if (monthStartDay == 1) {
      return DateFormat(showYear ? 'MMMM y' : 'MMMM').format(start);
    }
    final end = _cycleStartAt(offset + 1).subtract(const Duration(days: 1));
    final format = DateFormat(showYear ? 'MMM d, y' : 'MMM d');
    return '${format.format(start)} – ${format.format(end)}';
  }

  /// Label of the cycle picked with the month switcher (Transactions and
  /// Analytics).
  String get cycleLabel => _labelForCycle(_cycleOffset);

  /// Label of the current cycle — the dashboard always shows this one.
  String get currentCycleLabel => _labelForCycle(0);

  // Current-cycle totals — what the dashboard's budget meter and
  // Income/Expense tiles are scoped to, since a "monthly budget" should
  // reset each month rather than compare against all-time spending. These
  // ignore the month switcher on purpose: the dashboard is always "now".
  double get monthlyIncome => _transactions
      .where(
        (t) => t.type == TransactionType.income && _isInCurrentCycle(t.date),
      )
      .fold(0, (total, t) => total + t.amount);

  double get monthlyExpense => _transactions
      .where(
        (t) => t.type == TransactionType.expense && _isInCurrentCycle(t.date),
      )
      .fold(0, (total, t) => total + t.amount);

  /// Total spent in the cycle picked with the month switcher (Analytics).
  double get selectedCycleExpense => _transactions
      .where(
        (t) => t.type == TransactionType.expense && _isInSelectedCycle(t.date),
      )
      .fold(0, (total, t) => total + t.amount);

  /// Every transaction in the cycle picked with the month switcher, newest
  /// first — the Transactions tab's list.
  List<TransactionModel> get selectedCycleTransactions =>
      _transactions.where((t) => _isInSelectedCycle(t.date)).toList();

  /// The selected cycle's expenses in one category, newest first.
  List<TransactionModel> expensesInCategory(String categoryId) => _transactions
      .where(
        (t) =>
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            _isInSelectedCycle(t.date),
      )
      .toList();

  double get budgetRemaining => monthlyBudget - monthlyExpense;

  double get budgetUsedRatio =>
      monthlyBudget <= 0 ? 0 : (monthlyExpense / monthlyBudget).clamp(0, 2);

  /// Income and expense totals for each of the last 6 calendar months
  /// (oldest first, current month last) — the data behind the trend chart.
  List<MonthlyTotal> get lastSixMonths {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      final income = _transactions
          .where(
            (t) =>
                t.type == TransactionType.income &&
                t.date.year == month.year &&
                t.date.month == month.month,
          )
          .fold(0.0, (total, t) => total + t.amount);
      final expense = _transactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.date.year == month.year &&
                t.date.month == month.month,
          )
          .fold(0.0, (total, t) => total + t.amount);
      return MonthlyTotal(month: month, income: income, expense: expense);
    });
  }

  /// The selected cycle's expense totals per category, highest first.
  /// Categories with no expenses in that cycle are omitted.
  List<MapEntry<CategoryModel, double>> get expenseByCategory {
    final totals = <String, double>{};
    for (final t in _transactions.where(
      (t) => t.type == TransactionType.expense && _isInSelectedCycle(t.date),
    )) {
      if (t.categoryId == null) continue;
      totals[t.categoryId!] = (totals[t.categoryId!] ?? 0) + t.amount;
    }

    final entries = <MapEntry<CategoryModel, double>>[];
    for (final e in totals.entries) {
      final category = categoryById(e.key);
      if (category == null) continue;
      entries.add(MapEntry(category, e.value));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }

  Future<void> updateCurrency(CurrencyOption currency) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.set({
        'currencySymbol': currency.symbol,
        'currencyCode': currency.code,
      }, SetOptions(merge: true)),
    );
  }

  Future<void> updateMonthlyBudget(double budget) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.set({'monthlyBudget': budget}, SetOptions(merge: true)),
    );
  }

  Future<void> updateMonthStartDay(int day) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.set({'monthStartDay': day}, SetOptions(merge: true)),
    );
  }

  /// Pass null to remove the photo.
  Future<void> updatePhotoBase64(String? base64) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.set({'photoBase64': base64}, SetOptions(merge: true)),
    );
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.collection('transactions').add(transaction.toMap()),
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap()),
    );
  }

  Future<void> deleteTransaction(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(userDoc.collection('transactions').doc(id).delete());
  }

  /// Puts a just-deleted transaction back under its original id — the
  /// "Undo" behind a delete snackbar.
  Future<void> restoreTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap()),
    );
  }

  // A high ceiling mostly to stop runaway/accidental creation — the default
  // seed alone is 32 categories (27 expense + 5 income), so this needs
  // plenty of headroom above that.
  static const _maxCategories = 100;

  bool get canAddCategory => _categories.length < _maxCategories;

  Future<CategoryModel?> addCategory({
    required String name,
    required IconData icon,
    required TransactionType type,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null || !canAddCategory) return null;

    // Slots are counted per type, so expense categories spread across the
    // whole palette instead of sharing it with the income ones.
    final sameType = _categories.where((c) => c.type == type).length;
    final color =
        AppPalette.categorical[sameType % AppPalette.categorical.length];
    // Always-increasing, so a freshly added category sorts after every
    // existing one regardless of type.
    final sortOrder = DateTime.now().millisecondsSinceEpoch;
    final category = CategoryModel(
      id: '',
      name: name,
      icon: icon,
      color: color,
      type: type,
      sortOrder: sortOrder,
    );
    final ref = await _withTimeout(
      userDoc.collection('categories').add({
        ...category.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );

    return CategoryModel(
      id: ref.id,
      name: name,
      icon: icon,
      color: color,
      type: type,
      sortOrder: sortOrder,
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc
          .collection('categories')
          .doc(category.id)
          .set(category.toMap(), SetOptions(merge: true)),
    );
  }

  /// Persists a new manual order for exactly these categories (all of the
  /// same type) as consecutive sortOrder values, so they render in this
  /// exact sequence next time.
  Future<void> reorderCategories(List<CategoryModel> orderedCategories) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    final batch = _firestore.batch();
    for (var i = 0; i < orderedCategories.length; i++) {
      batch.update(
        userDoc.collection('categories').doc(orderedCategories[i].id),
        {'sortOrder': i},
      );
    }
    await _withTimeout(batch.commit());
  }

  Future<void> deleteCategory(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;

    final affected = await _withTimeout(
      userDoc
          .collection('transactions')
          .where('categoryId', isEqualTo: id)
          .get(),
    );

    final batch = _firestore.batch();
    for (final doc in affected.docs) {
      batch.update(doc.reference, {'categoryId': null});
    }
    batch.delete(userDoc.collection('categories').doc(id));
    await _withTimeout(batch.commit());
  }

  /// Seeds default categories and a starting budget for a brand-new
  /// account. Safe to call every sign-up — it no-ops if the user already
  /// has categories (e.g. this ran already, or synced from elsewhere).
  Future<void> seedDefaultsForNewUser() async {
    final userDoc = _userDoc;
    if (userDoc == null) return;

    final categoriesRef = userDoc.collection('categories');
    final existing = await _withTimeout(categoriesRef.limit(1).get());
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    batch.set(userDoc, {
      'monthlyBudget': 60000,
      'currencySymbol': 'Rs.',
      'currencyCode': 'PKR',
      'createdAt': FieldValue.serverTimestamp(),
    });

    var i = 0;
    for (final (index, seed) in _defaultSeedCategories.indexed) {
      final ref = categoriesRef.doc();
      batch.set(ref, {
        'name': seed.name,
        'iconKey': seed.iconKey,
        'color': _paletteSlot(index).toARGB32(),
        'type': 'expense',
        'sortOrder': i,
        'createdAt': FieldValue.serverTimestamp(),
      });
      i++;
    }
    for (final (index, seed) in _defaultIncomeSeedCategories.indexed) {
      final ref = categoriesRef.doc();
      batch.set(ref, {
        'name': seed.name,
        'iconKey': seed.iconKey,
        'color': _paletteSlot(index).toARGB32(),
        'type': 'income',
        'sortOrder': i,
        'createdAt': FieldValue.serverTimestamp(),
      });
      i++;
    }

    await _withTimeout(batch.commit());
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/currencies.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/monthly_total.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/budget_cycle.dart';
import 'package:monthly_traq/services/budget_win.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/services/daily_allowance.dart';

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

  CycleStats get _stats => CycleStats(_transactions);

  /// The budget cycle happening now.
  BudgetCycle get currentCycle =>
      BudgetCycle.containing(DateTime.now(), monthStartDay);

  // Which cycle Transactions and Analytics are showing, relative to the
  // current one — shared here so both tabs always show the same month.
  int _cycleOffset = 0;

  BudgetCycle get selectedCycle => currentCycle.shift(_cycleOffset);

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

  // Home is always about the current cycle and ignores the month switcher.
  double get monthlyIncome =>
      _stats.total(TransactionType.income, currentCycle);

  double get monthlyExpense =>
      _stats.total(TransactionType.expense, currentCycle);

  /// Transactions whose category counts toward the monthly budget —
  /// everything except categories marked "not in budget" (loan
  /// repayments, savings…). Uncategorized spending still counts.
  List<TransactionModel> get _budgetTransactions {
    final excluded = {
      for (final c in _categories)
        if (c.excludeFromBudget) c.id,
    };
    if (excluded.isEmpty) return _transactions;
    return [
      for (final t in _transactions)
        if (!excluded.contains(t.categoryId)) t,
    ];
  }

  /// This cycle's spending that counts against the budget.
  double get budgetSpent =>
      CycleStats(_budgetTransactions)
          .total(TransactionType.expense, currentCycle);

  /// This cycle's spending in "not in budget" categories — part of Spent,
  /// but left out of the budget.
  double get spentOutsideBudget => monthlyExpense - budgetSpent;

  /// This cycle's spending per "not in budget" category, largest first.
  List<CategoryTotal> get outsideBudgetTotals => [
    for (final total in _stats.byCategory(
      TransactionType.expense,
      currentCycle,
      _categories,
    ))
      if (total.category.excludeFromBudget) total,
  ];

  double get budgetRemaining => monthlyBudget - budgetSpent;

  double get budgetUsedRatio =>
      monthlyBudget <= 0 ? 0 : (budgetSpent / monthlyBudget).clamp(0, 2);

  int get daysLeftInCycle => currentCycle.daysLeft(DateTime.now());

  /// Last cycle ended within budget — Home celebrates it early in the new
  /// cycle. Null when there's nothing to celebrate.
  BudgetWin? get lastCycleWin => BudgetWin.forPreviousCycle(
    budget: monthlyBudget,
    transactions: _budgetTransactions,
    current: currentCycle,
    now: DateTime.now(),
  );

  /// What can be spent each day for the rest of the current cycle; null
  /// without a budget.
  DailyAllowance? get dailyAllowance => DailyAllowance.compute(
    budget: monthlyBudget,
    transactions: _budgetTransactions,
    cycle: currentCycle,
    now: DateTime.now(),
  );

  /// The current cycle's three biggest spending categories.
  List<CategoryTotal> get topSpending => _stats
      .byCategory(TransactionType.expense, currentCycle, _categories)
      .take(3)
      .toList();

  // Everything below follows the month switcher (Transactions, Analytics).

  /// Every transaction in the selected cycle, newest first.
  List<TransactionModel> get selectedCycleTransactions =>
      _transactions.where((t) => selectedCycle.contains(t.date)).toList();

  double selectedTotal(TransactionType type) =>
      _stats.total(type, selectedCycle);

  /// The same total for the cycle before the selected one.
  double previousTotal(TransactionType type) =>
      _stats.total(type, selectedCycle.previous);

  List<CategoryTotal> breakdown(TransactionType type) =>
      _stats.byCategory(type, selectedCycle, _categories);

  /// One category's transactions in the selected cycle, newest first. Pass
  /// [kUncategorizedId] for the ones without a category.
  List<TransactionModel> transactionsInCategory(
    String categoryId,
    TransactionType type,
  ) => _transactions
      .where(
        (t) =>
            t.type == type &&
            (t.categoryId ?? kUncategorizedId) == categoryId &&
            selectedCycle.contains(t.date),
      )
      .toList();

  List<DayTotal> dailyTotals(TransactionType type, {String? categoryId}) =>
      _stats.daily(type, selectedCycle, categoryId: categoryId);

  DayTotal? biggestDay(TransactionType type) =>
      _stats.biggestDay(type, selectedCycle);

  double dailyAverage(TransactionType type) =>
      _stats.dailyAverage(type, selectedCycle, DateTime.now());

  /// Income and spending for the six cycles ending with the selected one.
  List<MonthlyTotal> get trend => _stats.trend(selectedCycle);

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

  String? _savedId;
  DateTime? _savedAt;

  /// Whether [id] was added or edited in the last few seconds — lists give
  /// that row a brief glow so it's easy to spot.
  bool isJustSaved(String id) =>
      id == _savedId &&
      _savedAt != null &&
      DateTime.now().difference(_savedAt!) < const Duration(seconds: 4);

  void _markSaved(String id) {
    _savedId = id;
    _savedAt = DateTime.now();
  }

  /// Adds [transaction] and returns its new id.
  Future<String?> addTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return null;
    // Pick the id up front (what add() does) so the new row is known
    // before the write finishes.
    final doc = userDoc.collection('transactions').doc();
    _markSaved(doc.id);
    await _withTimeout(doc.set(transaction.toMap()));
    return doc.id;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    _markSaved(transaction.id);
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

  /// Permanently deletes every transaction on the account (categories and
  /// settings stay). Returns how many were deleted.
  Future<int> deleteAllTransactions() async {
    final userDoc = _userDoc;
    if (userDoc == null) return 0;
    return _deleteCollection(userDoc.collection('transactions'));
  }

  /// Deletes everything stored for the signed-in user — transactions,
  /// categories and the user document itself. The first step of deleting
  /// the account; the sign-in is deleted after this succeeds.
  Future<void> deleteAllUserData() async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _deleteCollection(userDoc.collection('transactions'));
    await _deleteCollection(userDoc.collection('categories'));
    await _deleteCollection(userDoc.collection('wallets'));
    await _deleteCollection(userDoc.collection('people'));
    await _deleteCollection(userDoc.collection('walletEntries'));
    await _deleteCollection(userDoc.collection('repayments'));
    await _deleteCollection(userDoc.collection('repaymentPayments'));
    await _deleteCollection(userDoc.collection('goals'));
    await _deleteCollection(userDoc.collection('goalEntries'));
    await _withTimeout(userDoc.delete());
  }

  /// Deletes every document in [collection], returning how many.
  Future<int> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final snap = await _withTimeout(collection.get());
    // Firestore batches cap at 500 writes.
    for (var i = 0; i < snap.docs.length; i += 450) {
      final batch = _firestore.batch();
      for (final doc in snap.docs.skip(i).take(450)) {
        batch.delete(doc.reference);
      }
      await _withTimeout(batch.commit());
    }
    return snap.docs.length;
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
    bool excludeFromBudget = false,
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
      excludeFromBudget: excludeFromBudget,
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
      excludeFromBudget: excludeFromBudget,
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

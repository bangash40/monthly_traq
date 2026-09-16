import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  (name: 'Food', icon: Icons.restaurant),
  (name: 'Transport', icon: Icons.directions_car),
  (name: 'Shopping', icon: Icons.shopping_bag),
  (name: 'Bills', icon: Icons.receipt_long),
  (name: 'Entertainment', icon: Icons.movie),
  (name: 'Health', icon: Icons.favorite),
  (name: 'Education', icon: Icons.school),
  (name: 'Other', icon: Icons.category),
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
  String currencySymbol = 'Rs.';
  bool isLoading = true;

  /// True while the most recent categories snapshot was served from local
  /// cache rather than confirmed by the server — the app's best signal for
  /// "you're offline (or a write is still in flight)".
  bool isOffline = false;

  Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(_writeTimeout, onTimeout: () => throw SyncTimeoutException());
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
      final currency = data?['currencySymbol'];
      if (currency is String && currency.isNotEmpty) currencySymbol = currency;
      notifyListeners();
    });

    _categoriesSub = userDoc
        .collection('categories')
        .orderBy('createdAt')
        .snapshots(includeMetadataChanges: true)
        .listen((snap) {
          _categories = snap.docs.map(CategoryModel.fromDoc).toList();
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

  @override
  void dispose() {
    _authSub?.cancel();
    _categoriesSub?.cancel();
    _transactionsSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
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

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Current-month totals — what the budget meter, the Income/Expense tiles,
  // and the category breakdown are actually scoped to, since a "monthly
  // budget" should reset each month rather than compare against all-time
  // spending.
  double get monthlyIncome => _transactions
      .where((t) => t.type == TransactionType.income && _isThisMonth(t.date))
      .fold(0, (total, t) => total + t.amount);

  double get monthlyExpense => _transactions
      .where((t) => t.type == TransactionType.expense && _isThisMonth(t.date))
      .fold(0, (total, t) => total + t.amount);

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

  /// This month's expense totals per category, highest first. Categories
  /// with no expenses yet this month are omitted.
  List<MapEntry<CategoryModel, double>> get expenseByCategory {
    final totals = <String, double>{};
    for (final t in _transactions.where(
      (t) => t.type == TransactionType.expense && _isThisMonth(t.date),
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

  Future<void> updateCurrencySymbol(String symbol) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.set({'currencySymbol': symbol}, SetOptions(merge: true)),
    );
  }

  Future<void> updateMonthlyBudget(double budget) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.set({'monthlyBudget': budget}, SetOptions(merge: true)),
    );
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(userDoc.collection('transactions').add(transaction.toMap()));
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(
      userDoc.collection('transactions').doc(transaction.id).update(transaction.toMap()),
    );
  }

  Future<void> deleteTransaction(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await _withTimeout(userDoc.collection('transactions').doc(id).delete());
  }

  // Beyond a generous cap, further categories are still allowed — each one
  // is told apart by its icon and name (not color alone), so palette colors
  // simply cycle rather than blocking category creation.
  static const _maxCategories = 30;

  bool get canAddCategory => _categories.length < _maxCategories;

  Future<CategoryModel?> addCategory({
    required String name,
    required IconData icon,
  }) async {
    final userDoc = _userDoc;
    if (userDoc == null || !canAddCategory) return null;

    final color =
        AppPalette.categorical[_categories.length % AppPalette.categorical.length];
    final category = CategoryModel(id: '', name: name, icon: icon, color: color);
    final ref = await _withTimeout(
      userDoc.collection('categories').add({
        ...category.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }),
    );

    return CategoryModel(id: ref.id, name: name, icon: icon, color: color);
  }

  Future<void> deleteCategory(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;

    final affected = await _withTimeout(
      userDoc.collection('transactions').where('categoryId', isEqualTo: id).get(),
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
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (var i = 0; i < _defaultSeedCategories.length; i++) {
      final seed = _defaultSeedCategories[i];
      final ref = categoriesRef.doc();
      batch.set(ref, {
        'name': seed.name,
        'iconCodePoint': seed.icon.codePoint,
        'color': AppPalette.categorical[i].toARGB32(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await _withTimeout(batch.commit());
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';

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
  bool isLoading = true;

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
      final budget = snap.data()?['monthlyBudget'];
      if (budget is num) monthlyBudget = budget.toDouble();
      notifyListeners();
    });

    _categoriesSub = userDoc
        .collection('categories')
        .orderBy('createdAt')
        .snapshots()
        .listen((snap) {
          _categories = snap.docs.map(CategoryModel.fromDoc).toList();
          isLoading = false;
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

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (total, t) => total + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (total, t) => total + t.amount);

  double get balance => totalIncome - totalExpense;

  double get budgetRemaining => monthlyBudget - totalExpense;

  double get budgetUsedRatio =>
      monthlyBudget <= 0 ? 0 : (totalExpense / monthlyBudget).clamp(0, 2);

  /// Expense totals per category, highest first. Categories with no
  /// expenses yet are omitted.
  List<MapEntry<CategoryModel, double>> get expenseByCategory {
    final totals = <String, double>{};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      if (t.categoryId == null) continue;
      totals[t.categoryId!] = (totals[t.categoryId!] ?? 0) + t.amount;
    }

    final entries = totals.entries
        .map((e) => MapEntry(categoryById(e.key), e.value))
        .whereType<MapEntry<CategoryModel, double>>()
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('transactions').add(transaction.toMap());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;
    await userDoc.collection('transactions').doc(id).delete();
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
    final ref = await userDoc.collection('categories').add({
      ...category.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return CategoryModel(id: ref.id, name: name, icon: icon, color: color);
  }

  Future<void> deleteCategory(String id) async {
    final userDoc = _userDoc;
    if (userDoc == null) return;

    final affected = await userDoc
        .collection('transactions')
        .where('categoryId', isEqualTo: id)
        .get();

    final batch = _firestore.batch();
    for (final doc in affected.docs) {
      batch.update(doc.reference, {'categoryId': null});
    }
    batch.delete(userDoc.collection('categories').doc(id));
    await batch.commit();
  }

  /// Seeds default categories and a starting budget for a brand-new
  /// account. Safe to call every sign-up — it no-ops if the user already
  /// has categories (e.g. this ran already, or synced from elsewhere).
  Future<void> seedDefaultsForNewUser() async {
    final userDoc = _userDoc;
    if (userDoc == null) return;

    final categoriesRef = userDoc.collection('categories');
    final existing = await categoriesRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    batch.set(userDoc, {
      'monthlyBudget': 60000,
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

    await batch.commit();
  }
}

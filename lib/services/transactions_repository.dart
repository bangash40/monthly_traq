import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';

/// Holds transactions, categories and the monthly budget for the signed-in
/// user. Backed by in-memory dummy data for now — the public API (streams of
/// computed totals via ChangeNotifier) is shaped so the dummy lists here can
/// later be swapped for Firestore-backed data without touching the UI.
class TransactionsRepository extends ChangeNotifier {
  TransactionsRepository() {
    _seedDummyData();
  }

  double monthlyBudget = 60000;

  final List<CategoryModel> _categories = [];
  final List<TransactionModel> _transactions = [];

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<TransactionModel> get transactions => List.unmodifiable(
    _transactions..sort((a, b) => b.date.compareTo(a.date)),
  );

  CategoryModel? categoryById(String? id) {
    if (id == null) return null;
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

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
        .map((e) => MapEntry(categoryById(e.key)!, e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(TransactionModel transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) return;
    _transactions[index] = transaction;
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Beyond a generous cap, further categories are still allowed — each one
  // is told apart by its icon and name (not color alone), so palette colors
  // simply cycle rather than blocking category creation.
  static const _maxCategories = 30;

  bool get canAddCategory => _categories.length < _maxCategories;

  CategoryModel? addCategory({required String name, required IconData icon}) {
    if (!canAddCategory) return null;
    final color =
        AppPalette.categorical[_categories.length % AppPalette.categorical.length];
    final category = CategoryModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      icon: icon,
      color: color,
    );
    _categories.add(category);
    notifyListeners();
    return category;
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    for (final t in _transactions.where((t) => t.categoryId == id).toList()) {
      updateTransaction(t.copyWith(categoryId: null));
    }
    notifyListeners();
  }

  void _seedDummyData() {
    const seedCategories = [
      (name: 'Food', icon: Icons.restaurant),
      (name: 'Transport', icon: Icons.directions_car),
      (name: 'Shopping', icon: Icons.shopping_bag),
      (name: 'Bills', icon: Icons.receipt_long),
      (name: 'Entertainment', icon: Icons.movie),
      (name: 'Health', icon: Icons.favorite),
      (name: 'Education', icon: Icons.school),
      (name: 'Other', icon: Icons.category),
    ];

    for (var i = 0; i < seedCategories.length; i++) {
      _categories.add(
        CategoryModel(
          id: 'cat_$i',
          name: seedCategories[i].name,
          icon: seedCategories[i].icon,
          color: AppPalette.categorical[i],
        ),
      );
    }

    final now = DateTime.now();
    DateTime daysAgo(int days) => now.subtract(Duration(days: days));

    final seed = <TransactionModel>[
      TransactionModel(
        id: 't1',
        title: 'Salary',
        amount: 80000,
        type: TransactionType.income,
        date: daysAgo(20),
      ),
      TransactionModel(
        id: 't2',
        title: 'Freelance project',
        amount: 12000,
        type: TransactionType.income,
        date: daysAgo(6),
      ),
      TransactionModel(
        id: 't3',
        title: 'Groceries',
        amount: 8500,
        type: TransactionType.expense,
        categoryId: 'cat_0',
        date: daysAgo(18),
      ),
      TransactionModel(
        id: 't4',
        title: 'Restaurant',
        amount: 3200,
        type: TransactionType.expense,
        categoryId: 'cat_0',
        date: daysAgo(3),
      ),
      TransactionModel(
        id: 't5',
        title: 'Fuel',
        amount: 4000,
        type: TransactionType.expense,
        categoryId: 'cat_1',
        date: daysAgo(15),
      ),
      TransactionModel(
        id: 't6',
        title: 'Ride-hailing',
        amount: 2500,
        type: TransactionType.expense,
        categoryId: 'cat_1',
        date: daysAgo(4),
      ),
      TransactionModel(
        id: 't7',
        title: 'New shoes',
        amount: 6800,
        type: TransactionType.expense,
        categoryId: 'cat_2',
        date: daysAgo(10),
      ),
      TransactionModel(
        id: 't8',
        title: 'Electricity bill',
        amount: 9200,
        type: TransactionType.expense,
        categoryId: 'cat_3',
        date: daysAgo(12),
      ),
      TransactionModel(
        id: 't9',
        title: 'Internet bill',
        amount: 1500,
        type: TransactionType.expense,
        categoryId: 'cat_3',
        date: daysAgo(11),
      ),
      TransactionModel(
        id: 't10',
        title: 'Movie night',
        amount: 2300,
        type: TransactionType.expense,
        categoryId: 'cat_4',
        date: daysAgo(7),
      ),
      TransactionModel(
        id: 't11',
        title: 'Streaming subscription',
        amount: 1200,
        type: TransactionType.expense,
        categoryId: 'cat_4',
        date: daysAgo(1),
      ),
      TransactionModel(
        id: 't12',
        title: 'Pharmacy',
        amount: 1800,
        type: TransactionType.expense,
        categoryId: 'cat_5',
        date: daysAgo(9),
      ),
      TransactionModel(
        id: 't13',
        title: 'Online course',
        amount: 5000,
        type: TransactionType.expense,
        categoryId: 'cat_6',
        date: daysAgo(14),
      ),
      TransactionModel(
        id: 't14',
        title: 'Miscellaneous',
        amount: 900,
        type: TransactionType.expense,
        categoryId: 'cat_7',
        date: daysAgo(2),
      ),
    ];

    _transactions.addAll(seed);
  }
}

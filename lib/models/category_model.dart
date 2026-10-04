import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/category_icons.dart';
import 'package:monthly_traq/models/transaction_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;
  // Null for categories created before manual reordering existed — they
  // keep their existing (createdAt) order and simply sort after any
  // category that has been given an explicit position.
  final int? sortOrder;

  /// Spending here isn't budget spending — loan repayments, savings
  /// deposits and the like. It still lowers the balance and shows in
  /// Spent, but the monthly budget and daily allowance leave it out.
  final bool excludeFromBudget;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = TransactionType.expense,
    this.sortOrder,
    this.excludeFromBudget = false,
  });

  /// Whether spending in this category counts against the monthly budget.
  bool get countsTowardBudget =>
      type == TransactionType.expense && !excludeFromBudget;

  factory CategoryModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      icon: iconForKey(data['iconKey'] as String? ?? defaultCategoryIconKey),
      color: Color(data['color'] as int),
      type: data['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      sortOrder: data['sortOrder'] as int?,
      excludeFromBudget: data['excludeFromBudget'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconKey': keyForIcon(icon),
      'color': color.toARGB32(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      if (sortOrder != null) 'sortOrder': sortOrder,
      'excludeFromBudget': excludeFromBudget,
    };
  }
}

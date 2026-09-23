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

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.type = TransactionType.expense,
    this.sortOrder,
  });

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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconKey': keyForIcon(icon),
      'color': color.toARGB32(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/category_icons.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory CategoryModel.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return CategoryModel(
      id: doc.id,
      name: data['name'] as String,
      icon: iconForKey(data['iconKey'] as String? ?? defaultCategoryIconKey),
      color: Color(data['color'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconKey': keyForIcon(icon),
      'color': color.toARGB32(),
    };
  }
}

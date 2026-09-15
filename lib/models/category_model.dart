import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      // Every codePoint stored here comes from the fixed icon set in
      // add_category_dialog.dart, which is referenced with const Icons.*
      // literals elsewhere — so icon tree-shaking still keeps these glyphs
      // even though this particular constructor call isn't itself const.
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(data['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      color: Color(data['color'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconCodePoint': icon.codePoint,
      'color': color.toARGB32(),
    };
  }
}

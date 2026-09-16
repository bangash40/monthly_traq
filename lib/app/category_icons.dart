import 'package:flutter/material.dart';

/// Every icon a category can use, keyed by a stable string stored in
/// Firestore. Icons are looked up through this fixed map — never
/// reconstructed from a stored int — so Flutter's icon tree-shaking can see
/// every icon this app actually uses and keep exactly those glyphs in
/// release builds.
const categoryIconsByKey = <String, IconData>{
  'category': Icons.category,
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'shopping_bag': Icons.shopping_bag,
  'receipt_long': Icons.receipt_long,
  'movie': Icons.movie,
  'favorite': Icons.favorite,
  'school': Icons.school,
  'fastfood': Icons.fastfood,
  'local_hospital': Icons.local_hospital,
  'flight': Icons.flight,
  'home': Icons.home,
  'pets': Icons.pets,
  'fitness_center': Icons.fitness_center,
  'card_giftcard': Icons.card_giftcard,
};

const defaultCategoryIconKey = 'category';

IconData iconForKey(String key) =>
    categoryIconsByKey[key] ?? categoryIconsByKey[defaultCategoryIconKey]!;

String keyForIcon(IconData icon) {
  for (final entry in categoryIconsByKey.entries) {
    if (entry.value == icon) return entry.key;
  }
  return defaultCategoryIconKey;
}

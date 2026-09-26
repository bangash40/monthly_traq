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
  'smartphone': Icons.smartphone,
  'content_cut': Icons.content_cut,
  'directions_run': Icons.directions_run,
  'people': Icons.people,
  'directions_bus': Icons.directions_bus,
  'checkroom': Icons.checkroom,
  'wine_bar': Icons.wine_bar,
  'smoking_rooms': Icons.smoking_rooms,
  'computer': Icons.computer,
  'build': Icons.build,
  'house': Icons.house,
  'weekend': Icons.weekend,
  'volunteer_activism': Icons.volunteer_activism,
  'casino': Icons.casino,
  'cookie': Icons.cookie,
  'child_care': Icons.child_care,
  'eco': Icons.eco,
  'shopping_basket': Icons.shopping_basket,
  'work': Icons.work,
  'trending_up': Icons.trending_up,
  'handshake': Icons.handshake,
  'emoji_events': Icons.emoji_events,
  'paid': Icons.paid,
  // Legacy key: Fruits was first seeded with Icons.apple, which is Apple's
  // brand logo rather than a fruit. Kept so categories already stored under
  // this key show the basket instead; listed last so [keyForIcon] resolves
  // the basket to 'shopping_basket' when such a category is re-saved.
  'apple': Icons.shopping_basket,
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

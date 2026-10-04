import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/app/category_icons.dart';

void main() {
  final grouped = [for (final g in categoryIconGroups) ...g.keys];

  test('every pickable icon is in exactly one group', () {
    final pickable = categoryIconsByKey.keys.where((k) => k != 'apple');
    for (final key in pickable) {
      expect(grouped.where((k) => k == key).length, 1, reason: key);
    }
  });

  test('groups only use known icons, and never the legacy apple key', () {
    for (final key in grouped) {
      expect(categoryIconsByKey.containsKey(key), isTrue, reason: key);
    }
    expect(grouped, isNot(contains('apple')));
  });

  test('keys round-trip, so a saved icon reloads as the same icon', () {
    for (final entry in categoryIconsByKey.entries) {
      if (entry.key == 'apple') continue;
      expect(keyForIcon(entry.value), entry.key);
      expect(iconForKey(entry.key), entry.value);
    }
  });

  test('older categories keep their icons', () {
    expect(iconForKey('handshake'), Icons.handshake);
    expect(iconForKey('apple'), Icons.shopping_basket);
    expect(iconForKey('unknown'), Icons.category);
  });

  test('plenty to choose from', () {
    expect(grouped.length, greaterThanOrEqualTo(120));
  });
}

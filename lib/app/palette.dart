import 'package:flutter/material.dart';

/// Categorical palette, fixed hue order (light mode) — do not reorder or
/// reassign; a category keeps its slot's color regardless of how it's
/// sorted or ranked in any given list.
class AppPalette {
  static const List<Color> categorical = [
    Color(0xFF2A78D6), // 1 blue
    Color(0xFFEB6834), // 2 orange
    Color(0xFF1BAF7A), // 3 aqua
    Color(0xFFEDA100), // 4 yellow
    Color(0xFFE87BA4), // 5 magenta
    Color(0xFF008300), // 6 green
    Color(0xFF4A3AA7), // 7 violet
    Color(0xFFE34948), // 8 red
  ];

  // Status colors — fixed across light and dark (validated to read on both).
  static const Color good = Color(0xFF0CA30C);
  static const Color warning = Color(0xFFFAB219);
  static const Color critical = Color(0xFFD03B3B);

  /// Income-amount text needs enough contrast against whatever surface
  /// it's sitting on, and that surface differs by theme — near-black
  /// green reads fine on a light card, but is nearly invisible on a dark
  /// one, where the brighter "good" green is what's legible instead.
  static Color successText(Brightness brightness) =>
      brightness == Brightness.dark ? good : const Color(0xFF006300);
}

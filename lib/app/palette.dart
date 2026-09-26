import 'package:flutter/material.dart';

/// Categorical palette, fixed hue order (light mode) — do not reorder or
/// reassign; a category keeps its slot's color regardless of how it's
/// sorted or ranked in any given list.
///
/// Twelve slots, deliberately with no pure green and no alarm red: green
/// already means "income" and red means "expense / over budget", so a
/// category wearing either would read as a status rather than a label.
class AppPalette {
  static const List<Color> categorical = [
    Color(0xFF2A78D6), // 1 blue
    Color(0xFFEB6834), // 2 orange
    Color(0xFF11A0A8), // 3 teal
    Color(0xFFEDA100), // 4 amber
    Color(0xFFD0479A), // 5 magenta
    Color(0xFF6A4BC4), // 6 violet
    Color(0xFF8C5A3C), // 7 brown
    Color(0xFF3FA7E0), // 8 sky
    Color(0xFF9B4DCA), // 9 purple
    Color(0xFFE87BA4), // 10 pink
    Color(0xFF5F6F7F), // 11 slate
    Color(0xFF3F51B5), // 12 indigo
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

  /// [warning] is fine as a fill, but as text on a light surface it's only
  /// ~1.9:1 — a darker amber carries the same meaning at readable contrast.
  static Color warningText(Brightness brightness) =>
      brightness == Brightness.dark ? warning : const Color(0xFF8A5A00);

  /// Chart series colors. Income and expense bars differ in lightness as
  /// well as hue, so the pair still reads apart for red-green colorblind
  /// users — lighter income over darker expense on light surfaces, and the
  /// reverse emphasis on dark ones, where a dark red would disappear.
  static Color incomeChart(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF5CCB5F) : good;

  static Color expenseChart(Brightness brightness) =>
      brightness == Brightness.dark ? critical : const Color(0xFFA62B2B);
}

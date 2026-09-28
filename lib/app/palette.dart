import 'package:flutter/material.dart';

/// Category colors, in a fixed slot order — do not reorder or reassign; a
/// category keeps its slot's color however it's sorted or ranked.
///
/// Twelve slots with no pure green and no alarm red: green means income and
/// red means spending in every theme, so a category wearing either would
/// read as a status rather than a label. Money colors live in [MoneyColors]
/// (theme.dart), not here.
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

  /// Transactions whose category was deleted.
  static const Color uncategorized = Color(0xFF5F6F7F);
}

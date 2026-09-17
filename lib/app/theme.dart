import 'package:flutter/material.dart';

// Light mode — "Sage Mint", chosen to pair with the forest-green dark theme.
const kLightBackground = Color(0xFFEAF6EE);
const kLightSurface = Color(0xFFFFFFFF);
const kLightPrimary = Color(0xFF3F7A5C);
const kLightPrimaryTint = Color(0xFFB7DEC5);
const kLightPrimarySoft = Color(0xFFDCF0E3);

// Dark mode — from https://colorhunt.co/palette/091413285a48408a71b0e4cc
const kDarkBackground = Color(0xFF091413);
const kDarkSurface = Color(0xFF14241F);
// Deep green derived from that palette's 408A71 — darkened enough to carry
// white button/app bar text at proper contrast (408A71 itself falls just
// short of the 4.5:1 body-text minimum).
const kDarkPrimary = Color(0xFF2F7A61);
const kDarkPrimaryTint = Color(0xFFB0E4CC);
const kDarkPrimarySoft = Color(0xFF285A48);

/// The primary hue, in whichever shade is safe to use as text/icon/dot
/// color directly on the current theme's background or surface — not
/// necessarily the same shade `colorScheme.primary` uses for fills (a
/// filled button carries white text on top, so it can stay bold; bare
/// foreground content next to that same background needs more contrast).
Color themeAccent(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? kDarkPrimaryTint
      : kLightPrimary;
}

ThemeData monthlyTraqLightTheme() {
  return _buildTheme(
    brightness: Brightness.light,
    background: kLightBackground,
    surface: kLightSurface,
    primary: kLightPrimary,
    // kLightPrimary already has enough contrast to double as text/icon
    // color directly on the light background.
    accent: kLightPrimary,
  );
}

ThemeData monthlyTraqDarkTheme() {
  return _buildTheme(
    brightness: Brightness.dark,
    background: kDarkBackground,
    surface: kDarkSurface,
    primary: kDarkPrimary,
    // kDarkPrimary reads great as a filled button (white text on top of
    // it) but fails contrast as text/icon color sitting directly on the
    // dark background/surface — the lighter tint is what's legible there.
    accent: kDarkPrimaryTint,
  );
}

ThemeData _buildTheme({
  required Brightness brightness,
  required Color background,
  required Color surface,
  required Color primary,
  required Color accent,
}) {
  final borderRadius = BorderRadius.circular(20);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    primary: primary,
    surface: surface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: background,
    colorScheme: colorScheme,
    cardColor: surface,
    dialogTheme: DialogThemeData(backgroundColor: surface),

    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withValues(alpha: 0.16),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? accent
              : colorScheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          color: states.contains(WidgetState.selected)
              ? accent
              : colorScheme.onSurfaceVariant,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,

      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: accent, width: 2),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),

      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey.shade900,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

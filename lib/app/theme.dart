import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Light mode default — "Sage Mint", chosen to pair with the forest-green
// dark theme.
const kLightBackground = Color(0xFFEAF6EE);
const kLightSurface = Color(0xFFFFFFFF);
const kLightPrimary = Color(0xFF3F7A5C);

// Dark mode default — from https://colorhunt.co/palette/091413285a48408a71b0e4cc
const kDarkBackground = Color(0xFF091413);
const kDarkSurface = Color(0xFF14241F);
// Deep green derived from that palette's 408A71 — darkened enough to carry
// white button text at proper contrast (408A71 itself falls just
// short of the 4.5:1 body-text minimum).
const kDarkPrimary = Color(0xFF2F7A61);
const kDarkPrimaryTint = Color(0xFFB0E4CC);

/// A selectable app color palette — a brightness (light or dark) plus the
/// background/surface/primary/accent quartet [_buildTheme] needs. Every
/// preset here has been checked by hand for WCAG contrast: `primary` carries
/// white text (filled buttons, the add button) at >= 4.5:1, and `accent` carries
/// bare text/icons directly on [background]/[surface] at >= 4.5:1 too.
class AppThemePreset {
  final String id;
  final String name;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color primary;
  final Color accent;

  const AppThemePreset({
    required this.id,
    required this.name,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.primary,
    required this.accent,
  });

  ThemeData toThemeData() => _buildTheme(
    brightness: brightness,
    background: background,
    surface: surface,
    primary: primary,
    accent: accent,
  );
}

const kLightThemePresets = [
  AppThemePreset(
    id: 'sage_mint',
    name: 'Sage Mint',
    brightness: Brightness.light,
    background: kLightBackground,
    surface: kLightSurface,
    primary: kLightPrimary,
    // kLightPrimary already has enough contrast to double as text/icon
    // color directly on the light background.
    accent: kLightPrimary,
  ),
  AppThemePreset(
    id: 'sky_blue',
    name: 'Sky Blue',
    brightness: Brightness.light,
    background: Color(0xFFEAF3FC),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF2E6DA4),
    accent: Color(0xFF2E6DA4),
  ),
  AppThemePreset(
    id: 'blush_rose',
    name: 'Blush Rose',
    brightness: Brightness.light,
    background: Color(0xFFFCEEF1),
    surface: Color(0xFFFFFFFF),
    // Darkened from the palette pick's B85C74 — that shade falls just
    // short of 4.5:1 for white button text.
    primary: Color(0xFFA34D66),
    accent: Color(0xFFA34D66),
  ),
];

const kDarkThemePresets = [
  AppThemePreset(
    id: 'forest_green',
    name: 'Forest Green',
    brightness: Brightness.dark,
    background: kDarkBackground,
    surface: kDarkSurface,
    primary: kDarkPrimary,
    // kDarkPrimary reads great as a filled button (white text on top of
    // it) but fails contrast as text/icon color sitting directly on the
    // dark background/surface — the lighter tint is what's legible there.
    accent: kDarkPrimaryTint,
  ),
  AppThemePreset(
    id: 'midnight_indigo',
    name: 'Midnight Indigo',
    brightness: Brightness.dark,
    background: Color(0xFF090817),
    surface: Color(0xFF131132),
    primary: Color(0xFF3C36A1),
    accent: Color(0xFFB1AEE0),
  ),
  AppThemePreset(
    id: 'wine_burgundy',
    name: 'Wine Burgundy',
    brightness: Brightness.dark,
    background: Color(0xFF18070D),
    surface: Color(0xFF330F1D),
    primary: Color(0xFF8E294F),
    accent: Color(0xFFE0AEC1),
  ),
];

const kDefaultLightPresetId = 'sage_mint';
const kDefaultDarkPresetId = 'forest_green';

AppThemePreset presetById(String id, List<AppThemePreset> from) =>
    from.firstWhere((p) => p.id == id, orElse: () => from.first);

/// The primary hue, in whichever shade is safe to use as text/icon/dot
/// color directly on the current theme's background or surface — not
/// necessarily the same shade `colorScheme.primary` uses for fills (a
/// filled button carries white text on top, so it can stay bold; bare
/// foreground content next to that same background needs more contrast).
/// Reads from the active [ThemeData], so it follows whichever palette
/// preset is currently selected.
Color themeAccent(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;

ThemeData _buildTheme({
  required Brightness brightness,
  required Color background,
  required Color surface,
  required Color primary,
  required Color accent,
}) {
  final borderRadius = BorderRadius.circular(20);
  final isDark = brightness == Brightness.dark;
  final baseScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    primary: primary,
    surface: surface,
  );
  // Every role a visible widget actually paints with is pinned to this
  // preset's own four colors, rather than left to Material's seed-derived
  // tones — those drift slightly off-palette per preset (the bottom bar,
  // add button and chip/segment highlights all used to).
  final selectedTint = Color.alphaBlend(accent.withValues(alpha: 0.16), surface);
  final colorScheme = baseScheme.copyWith(
    secondary: accent,
    secondaryContainer: selectedTint,
    onSecondaryContainer: baseScheme.onSurface,
    surfaceContainer: surface,
    surfaceContainerHighest: Color.lerp(surface, accent, isDark ? 0.12 : 0.08),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: background,
    colorScheme: colorScheme,
    cardColor: surface,
    dialogTheme: DialogThemeData(backgroundColor: surface),

    // App bars sit flat on the page background with a bold title, keeping
    // the saturated primary for the actions that matter (buttons, the add
    // button) instead of spending it on every screen's header.
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      // Transparent status bar so the app bar's color runs up behind the
      // clock (Android otherwise lays a translucent black scrim over it),
      // and the system navigation bar matches the bottom app bar.
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor: surface,
        systemNavigationBarDividerColor: surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    ),

    bottomAppBarTheme: BottomAppBarThemeData(color: surface),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
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

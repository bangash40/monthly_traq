import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monthly_traq/app/text_styles.dart';

/// One mode of a theme: the four colors the design specifies for it, plus
/// the text color that sits on [primary]. [primary] fills buttons and the
/// balance card; [accent] is the same hue in a shade that's safe as text
/// or icon color directly on [background] and [surface].
class ThemePalette {
  final Color background;
  final Color surface;
  final Color primary;
  final Color accent;
  final Color onPrimary;

  const ThemePalette({
    required this.background,
    required this.surface,
    required this.primary,
    required this.accent,
    this.onPrimary = Colors.white,
  });
}

/// A selectable theme: one brand hue with a light and a dark palette.
class AppTheme {
  final String id;
  final String name;
  final ThemePalette light;
  final ThemePalette dark;

  const AppTheme({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
  });

  ThemePalette palette(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  ThemeData themeData(Brightness brightness) => buildTheme(this, brightness);
}

const kDefaultThemeId = 'indigo';

const kAppThemes = [
  AppTheme(
    id: 'indigo',
    name: 'Indigo',
    light: ThemePalette(
      background: Color(0xFFF4F5FA),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF4338CA),
      accent: Color(0xFF4338CA),
    ),
    dark: ThemePalette(
      background: Color(0xFF0D0F1A),
      surface: Color(0xFF161927),
      primary: Color(0xFF4F46E5),
      accent: Color(0xFFA9A5FF),
    ),
  ),
  AppTheme(
    id: 'ocean',
    name: 'Ocean',
    light: ThemePalette(
      background: Color(0xFFF2F6F9),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF0B63A6),
      accent: Color(0xFF0B63A6),
    ),
    dark: ThemePalette(
      background: Color(0xFF0A1219),
      surface: Color(0xFF111D28),
      primary: Color(0xFF1570B5),
      accent: Color(0xFF7CC1F2),
    ),
  ),
  AppTheme(
    id: 'sage',
    name: 'Sage',
    light: ThemePalette(
      background: Color(0xFFF2F6F3),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF2F6B55),
      accent: Color(0xFF2F6B55),
    ),
    dark: ThemePalette(
      background: Color(0xFF0A1411),
      surface: Color(0xFF12201A),
      primary: Color(0xFF2F7A61),
      accent: Color(0xFF8FD6B6),
    ),
  ),
  AppTheme(
    id: 'plum',
    name: 'Plum',
    light: ThemePalette(
      background: Color(0xFFF7F4F9),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF6D3A8C),
      accent: Color(0xFF6D3A8C),
    ),
    dark: ThemePalette(
      background: Color(0xFF120D16),
      surface: Color(0xFF1C1522),
      primary: Color(0xFF7E45A3),
      accent: Color(0xFFD4B3EE),
    ),
  ),
  AppTheme(
    id: 'rose',
    name: 'Rose',
    light: ThemePalette(
      background: Color(0xFFFAF4F5),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFFA8324F),
      accent: Color(0xFFA8324F),
    ),
    dark: ThemePalette(
      background: Color(0xFF160C0F),
      surface: Color(0xFF221418),
      primary: Color(0xFFB23A5B),
      accent: Color(0xFFF4A9BC),
    ),
  ),
  AppTheme(
    id: 'saffron',
    name: 'Saffron',
    light: ThemePalette(
      background: Color(0xFFF8F5EF),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF8F4E00),
      accent: Color(0xFF8F4E00),
    ),
    dark: ThemePalette(
      background: Color(0xFF14100A),
      surface: Color(0xFF1E1811),
      primary: Color(0xFF9A5A0C),
      accent: Color(0xFFF2BD72),
    ),
  ),
  AppTheme(
    id: 'graphite',
    name: 'Graphite',
    light: ThemePalette(
      background: Color(0xFFF4F4F5),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF1F2024),
      accent: Color(0xFF1F2024),
    ),
    // The one theme whose dark primary is light, so it carries dark text.
    dark: ThemePalette(
      background: Color(0xFF0C0C0E),
      surface: Color(0xFF17171A),
      primary: Color(0xFFEDEDEF),
      accent: Color(0xFFF4F4F5),
      onPrimary: Color(0xFF17171A),
    ),
  ),
];

AppTheme themeById(String id) =>
    kAppThemes.firstWhere((t) => t.id == id, orElse: () => kAppThemes.first);

/// Corner radii from the design's shape scale.
class AppRadius {
  static const sheet = 28.0;
  static const largeCard = 24.0;
  static const card = 20.0;
  static const button = 16.0;
  static const input = 14.0;
  static const iconTile = 12.0;
  static const bar = 4.0;
}

/// Money colors are fixed across every theme, so green always means income
/// and red always means spending. The "text" shades are for words and
/// numbers; the "fill" shades are for icons, bars and chart marks.
class MoneyColors {
  static const incomeTextLight = Color(0xFF0A7A4D);
  static const incomeTextDark = Color(0xFF3DD68C);
  static const spendingTextLight = Color(0xFFC4323A);
  static const spendingTextDark = Color(0xFFFF8589);
  static const warningTextLight = Color(0xFF8A5A00);
  static const warningTextDark = Color(0xFFF5B84A);

  static const incomeFillLight = Color(0xFF16A05E);
  static const incomeFillDark = Color(0xFF3DD68C);
  static const spendingFillLight = Color(0xFFE5484D);
  static const spendingFillDark = Color(0xFFFF6B70);
  static const warningFillLight = Color(0xFFF5A524);
  static const warningFillDark = Color(0xFFF5B84A);
}

/// Every color a screen paints with, resolved for the active theme and
/// mode. Read it with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Brightness brightness;
  final Color background;
  final Color surface;

  /// One step up from the page: keypad keys, segmented tracks, read-only
  /// inputs, neutral badges.
  final Color surfaceHigh;
  final Color primary;
  final Color onPrimary;
  final Color accent;

  /// The brand hue as a soft tint: secondary buttons, the selected nav
  /// pill, settings icon tiles.
  final Color primarySoft;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color hairline;
  final Color income;
  final Color spending;
  final Color warning;
  final Color incomeFill;
  final Color spendingFill;
  final Color warningFill;

  /// Light mode lifts cards with a soft two-layer shadow; dark mode has no
  /// shadows and relies on lighter surfaces instead.
  final List<BoxShadow> cardShadow;

  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.primarySoft,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.hairline,
    required this.income,
    required this.spending,
    required this.warning,
    required this.incomeFill,
    required this.spendingFill,
    required this.warningFill,
    required this.cardShadow,
  });

  bool get isDark => brightness == Brightness.dark;

  factory AppColors.resolve(ThemePalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    const inkLight = Color(0xFF141726);
    return AppColors(
      brightness: brightness,
      background: p.background,
      surface: p.surface,
      surfaceHigh: isDark
          ? Color.alphaBlend(const Color(0x14FFFFFF), p.surface)
          : Color.alphaBlend(inkLight.withValues(alpha: 0.06), p.background),
      primary: p.primary,
      onPrimary: p.onPrimary,
      accent: p.accent,
      primarySoft: isDark
          ? Color.alphaBlend(p.accent.withValues(alpha: 0.16), p.surface)
          : Color.alphaBlend(p.primary.withValues(alpha: 0.10), p.surface),
      ink: isDark ? const Color(0xFFF2F3F8) : inkLight,
      muted: isDark ? const Color(0xFFA0A5B5) : const Color(0xFF5E6475),
      faint: isDark ? const Color(0xFF6E7384) : const Color(0xFF8B90A0),
      hairline: isDark ? const Color(0x1AFFFFFF) : const Color(0x17141726),
      income: isDark ? MoneyColors.incomeTextDark : MoneyColors.incomeTextLight,
      spending: isDark
          ? MoneyColors.spendingTextDark
          : MoneyColors.spendingTextLight,
      warning: isDark
          ? MoneyColors.warningTextDark
          : MoneyColors.warningTextLight,
      incomeFill: isDark
          ? MoneyColors.incomeFillDark
          : MoneyColors.incomeFillLight,
      spendingFill: isDark
          ? MoneyColors.spendingFillDark
          : MoneyColors.spendingFillLight,
      warningFill: isDark
          ? MoneyColors.warningFillDark
          : MoneyColors.warningFillLight,
      cardShadow: isDark
          ? const []
          : const [
              BoxShadow(
                color: Color(0x0A141726),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
              BoxShadow(
                color: Color(0x0F141726),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
    );
  }

  /// A category color as the soft tint behind its icon (the design's 14%).
  Color tint(Color color) =>
      Color.alphaBlend(color.withValues(alpha: isDark ? 0.18 : 0.14), surface);

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) =>
      other is AppColors && t >= 0.5 ? other : this;
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

/// The brand hue in its text-safe shade. Kept as a shorthand because many
/// widgets only need this one color.
Color themeAccent(BuildContext context) => context.colors.accent;

ThemeData buildTheme(AppTheme theme, Brightness brightness) {
  final p = theme.palette(brightness);
  final c = AppColors.resolve(p, brightness);
  final isDark = c.isDark;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: c.primarySoft,
    onPrimaryContainer: c.accent,
    secondary: c.accent,
    onSecondary: isDark ? p.background : Colors.white,
    secondaryContainer: c.primarySoft,
    onSecondaryContainer: c.ink,
    tertiary: c.accent,
    onTertiary: p.onPrimary,
    error: c.spending,
    onError: Colors.white,
    surface: p.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.muted,
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: c.surfaceHigh,
    surfaceContainerHighest: c.surfaceHigh,
    outline: c.faint,
    outlineVariant: c.hairline,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: isDark ? const Color(0xFFE9EAF1) : const Color(0xFF1E2130),
    onInverseSurface: isDark ? const Color(0xFF141726) : Colors.white,
    // Snackbar actions ("Undo") use this, on the inverse surface — which is
    // light in dark mode and dark in light mode, so borrow the other mode's
    // text-safe accent. (The dark primaries fail contrast on a light
    // snackbar; Graphite's is nearly invisible.)
    inversePrimary: isDark ? theme.light.accent : theme.dark.accent,
  );

  RoundedRectangleBorder rounded(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: AppText.fontFamily,
    colorScheme: scheme,
    extensions: [c],
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    cardColor: p.surface,
    dividerColor: c.hairline,
    dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: c.ink),
    textTheme: TextTheme(
      displaySmall: AppText.balance,
      headlineMedium: AppText.titleLarge,
      headlineSmall: AppText.screenTitle,
      titleLarge: AppText.section.copyWith(fontSize: 20),
      titleMedium: AppText.rowTitle,
      titleSmall: AppText.label.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      bodySmall: AppText.caption,
      labelLarge: AppText.button.copyWith(fontSize: 15),
      labelMedium: AppText.caption,
      labelSmall: AppText.tiny,
    ).apply(bodyColor: c.ink, displayColor: c.ink),

    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: c.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.section.copyWith(fontSize: 20, color: c.ink),
      // Transparent status bar so the page color runs up behind the clock,
      // and a system navigation bar that matches the bottom bar.
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor: p.surface,
        systemNavigationBarDividerColor: p.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        disabledBackgroundColor: c.surfaceHigh,
        disabledForegroundColor: c.faint,
        elevation: 0,
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: AppText.button,
        shape: rounded(AppRadius.button),
      ),
    ),
    // Filled buttons are the design's "secondary": a soft tint of the hue.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primarySoft,
        foregroundColor: c.accent,
        elevation: 0,
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: AppText.button,
        shape: rounded(AppRadius.button),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: p.surface,
        foregroundColor: c.ink,
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: AppText.button,
        side: BorderSide(color: c.hairline),
        shape: rounded(AppRadius.button),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.accent,
        textStyle: AppText.rowTitle.copyWith(fontWeight: FontWeight.w800),
        shape: rounded(AppRadius.button),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: c.ink),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      hintStyle: AppText.body.copyWith(color: c.faint),
      labelStyle: AppText.body.copyWith(color: c.muted),
      prefixIconColor: c.muted,
      suffixIconColor: c.muted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: inputBorder(c.hairline),
      enabledBorder: inputBorder(c.hairline),
      disabledBorder: inputBorder(c.hairline),
      focusedBorder: inputBorder(c.accent, 1.6),
      errorBorder: inputBorder(c.spending, 1.4),
      focusedErrorBorder: inputBorder(c.spending, 1.6),
      errorStyle: AppText.caption.copyWith(color: c.spending),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? p.onPrimary : c.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? p.primary : c.surfaceHigh,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: c.accent,
      inactiveTrackColor: c.surfaceHigh,
      thumbColor: p.surface,
      overlayColor: c.accent.withValues(alpha: 0.12),
      trackHeight: 4,
      thumbShape: _RingThumbShape(ring: c.accent, fill: p.surface),
      activeTickMarkColor: Colors.transparent,
      inactiveTickMarkColor: Colors.transparent,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      elevation: 6,
      focusElevation: 6,
      hoverElevation: 8,
      highlightElevation: 8,
      shape: rounded(24),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      modalBackgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: c.hairline,
      dragHandleSize: const Size(40, 5),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: rounded(AppRadius.largeCard),
      titleTextStyle: AppText.section.copyWith(fontSize: 20, color: c.ink),
      contentTextStyle: AppText.body.copyWith(color: c.muted),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: rounded(AppRadius.button),
      textStyle: AppText.rowTitle.copyWith(color: c.ink),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: AppText.rowTitle.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: rounded(AppRadius.button),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),

    listTileTheme: ListTileThemeData(iconColor: c.muted, textColor: c.ink),

    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: p.primary,
      headerForegroundColor: p.onPrimary,
      shape: rounded(AppRadius.largeCard),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.accent,
      selectionHandleColor: c.accent,
      selectionColor: c.accent.withValues(alpha: 0.25),
    ),
  );
}

/// The design's slider thumb: a hollow ring in the accent color.
class _RingThumbShape extends SliderComponentShape {
  final Color ring;
  final Color fill;

  const _RingThumbShape({required this.ring, required this.fill});

  static const _radius = 12.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, _radius, Paint()..color = fill);
    canvas.drawCircle(
      center,
      _radius - 1.5,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}

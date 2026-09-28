import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/app/theme.dart';

/// WCAG 2 contrast ratio between two opaque colors.
double contrast(Color a, Color b) {
  double luminance(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('the design\'s seven themes, Indigo first and default', () {
    expect(kAppThemes.map((t) => t.name), [
      'Indigo',
      'Ocean',
      'Sage',
      'Plum',
      'Rose',
      'Saffron',
      'Graphite',
    ]);
    expect(kDefaultThemeId, 'indigo');
    expect(themeById('nope').id, 'indigo');
  });

  for (final theme in kAppThemes) {
    for (final brightness in Brightness.values) {
      group('${theme.name} ${brightness.name}', () {
        final data = theme.themeData(brightness);
        final c = data.extension<AppColors>()!;
        final p = theme.palette(brightness);

        void readable(String what, Color fg, Color bg) {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$what is ${contrast(fg, bg).toStringAsFixed(2)}:1',
          );
        }

        test('builds with the right brightness and font', () {
          expect(data.brightness, brightness);
          expect(data.colorScheme.primary, p.primary);
          expect(data.textTheme.bodyMedium?.fontFamily, 'Manrope');
        });

        test('text on the brand color is readable', () {
          readable('onPrimary on primary', p.onPrimary, p.primary);
        });

        test('accent works as text on the page and on cards', () {
          readable('accent on background', c.accent, c.background);
          readable('accent on surface', c.accent, c.surface);
        });

        test('body and muted text are readable', () {
          readable('ink on background', c.ink, c.background);
          readable('muted on background', c.muted, c.background);
          readable('muted on surface', c.muted, c.surface);
        });

        test('money colors are readable as text', () {
          for (final (name, color) in [
            ('income', c.income),
            ('spending', c.spending),
            ('warning', c.warning),
          ]) {
            readable('$name on background', color, c.background);
            readable('$name on surface', color, c.surface);
          }
        });

        test('snackbar text and its Undo action are readable', () {
          final s = data.colorScheme;
          readable('snackbar text', s.onInverseSurface, s.inverseSurface);
          readable('snackbar action', s.inversePrimary, s.inverseSurface);
        });
      });
    }
  }

  test('Graphite dark is the one theme with dark text on its buttons', () {
    for (final theme in kAppThemes) {
      final darkText = theme.dark.onPrimary != Colors.white;
      expect(darkText, theme.id == 'graphite', reason: theme.name);
    }
  });

  test('categories never wear a money color', () {
    final money = {
      MoneyColors.incomeFillLight,
      MoneyColors.incomeFillDark,
      MoneyColors.spendingFillLight,
      MoneyColors.spendingFillDark,
    };
    expect(AppPalette.categorical, hasLength(12));
    for (final color in AppPalette.categorical) {
      expect(money.contains(color), isFalse);
      // No pure green: hue well away from income's green.
      final hue = HSLColor.fromColor(color).hue;
      expect(hue > 80 && hue < 160, isFalse, reason: color.toString());
    }
  });
}

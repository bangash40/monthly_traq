import 'package:flutter/material.dart';

/// The app's type scale, defined once. Sizes and weights only — color comes
/// from the surrounding theme, or a `.copyWith(color: ...)` where a style
/// needs the muted onSurfaceVariant tone. The Font Size setting still
/// scales all of these through the app-wide TextScaler.
class AppText {
  /// The dashboard balance.
  static const balance = TextStyle(fontSize: 34, fontWeight: FontWeight.bold);

  /// The amount being typed on the keypad sheet.
  static const amountEntry = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
  );

  /// Login / sign-up headline.
  static const authTitle = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);

  /// Onboarding slide title.
  static const slideTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  /// Stat tile values.
  static const statValue = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

  /// Section and card headings ("Recent transactions", "Monthly trend").
  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  /// Money amounts in lists.
  static const amount = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  /// Card labels, meter captions, secondary lines.
  static const label = TextStyle(fontSize: 13);
  static const labelStrong = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  /// Dates, legends, small print.
  static const caption = TextStyle(fontSize: 12);

  /// Nav labels, category grid labels, chart axis.
  static const tiny = TextStyle(fontSize: 11);
}

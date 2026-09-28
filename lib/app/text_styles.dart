import 'package:flutter/material.dart';

/// The design's type scale: one family (Manrope), sizes and weights only.
/// Color comes from the theme, or a `.copyWith(color: ...)`. Styles that
/// show money use tabular figures so amounts line up in lists. The Font
/// Size setting still scales everything through the app-wide TextScaler.
class AppText {
  static const fontFamily = 'Manrope';
  static const _tabular = [FontFeature.tabularFigures()];

  /// The amount being typed on the Add screen. 46/52 · 800.
  static const display = TextStyle(
    fontSize: 46,
    height: 52 / 46,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    fontFeatures: _tabular,
  );

  /// The balance on the Home card. 38/44 · 800.
  static const balance = TextStyle(
    fontSize: 38,
    height: 44 / 38,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    fontFeatures: _tabular,
  );

  /// A single big total, e.g. one category's spending. 34/40 · 800.
  static const hero = TextStyle(
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    fontFeatures: _tabular,
  );

  /// Login, sign-up and onboarding headlines. 30/36 · 800.
  static const titleLarge = TextStyle(
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );

  /// Tab page titles ("Transactions"). 28/34 · 800.
  static const screenTitle = TextStyle(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  /// Card amounts like "Rs. 21,400 left" and the donut total. 26/32 · 800.
  static const amountLarge = TextStyle(
    fontSize: 26,
    height: 32 / 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    fontFeatures: _tabular,
  );

  /// Section headings ("Monthly budget", "Recent"). 17/24 · 800.
  static const section = TextStyle(
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w800,
  );

  /// Small stat values (In / Out / Net, top spending). 17/24 · 800.
  static const statValue = TextStyle(
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
  );

  /// List row titles ("Groceries"). 15/22 · 700.
  static const rowTitle = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w700,
  );

  /// Amounts in list rows. 15/22 · 800, tabular.
  static const amount = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
  );

  /// Running text. 15/22 · 500.
  static const body = TextStyle(
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w500,
  );

  static const button = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w800,
  );

  /// Secondary lines under a row title ("Food · Today"). 13/18 · 500.
  static const label = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
  );

  /// Captions and small labels ("64% used"). 12/16 · 600.
  static const caption = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
  );

  /// Section overlines ("BUDGET"). 12/16 · 800, tracked out. Pass the text
  /// already uppercased.
  static const overline = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.9,
  );

  /// Nav labels, chart axes, category grid labels.
  static const tiny = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
  );

  /// [style] with tabular figures, for any other place numbers must line up.
  static TextStyle tabular(TextStyle style) =>
      style.copyWith(fontFeatures: _tabular);
}

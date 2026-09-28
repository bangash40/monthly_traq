import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// The typographic minus, which lines up with "+" in tabular figures.
const kMinus = '−';

/// Which sign an amount is shown with.
enum MoneySign {
  /// No sign, even for a negative value's magnitude.
  none,

  /// Always "+", for money in.
  income,

  /// Always "−", for money out.
  expense,

  /// "+" for positive, "−" for negative, none for zero (net totals).
  auto,
}

/// Formats amounts the one way the whole app shows them: the currency
/// symbol, then the number, with digits grouped unless the user turned the
/// thousands separator off. Whole amounts show no decimals; anything with
/// cents shows two.
class MoneyFormatter {
  final String symbol;
  final bool grouping;

  const MoneyFormatter({this.symbol = 'Rs.', this.grouping = true});

  // Value equality, so the provider only rebuilds widgets when the currency
  // or separator setting actually changes.
  @override
  bool operator ==(Object other) =>
      other is MoneyFormatter &&
      other.symbol == symbol &&
      other.grouping == grouping;

  @override
  int get hashCode => Object.hash(symbol, grouping);

  /// The magnitude of [value], without symbol or sign: "3,450".
  String number(double value) {
    final magnitude = value.abs();
    final cents = (magnitude * 100).round();
    final hasFraction = cents % 100 != 0;
    final whole = grouping ? '#,##0' : '0';
    return NumberFormat(
      hasFraction ? '$whole.00' : whole,
      'en_US',
    ).format(cents / 100);
  }

  /// "Rs. 3,450", "−Rs. 3,450", "+Rs. 120,000" — or without the symbol
  /// when [withSymbol] is false ("+120,000").
  String format(
    double value, {
    MoneySign sign = MoneySign.none,
    bool withSymbol = true,
  }) {
    final body = withSymbol ? '$symbol ${number(value)}' : number(value);
    return switch (sign) {
      MoneySign.none => body,
      MoneySign.income => '+$body',
      MoneySign.expense => '$kMinus$body',
      MoneySign.auto =>
        value > 0
            ? '+$body'
            : value < 0
            ? '$kMinus$body'
            : body,
    };
  }

  /// Short axis labels: "850", "12k", "120k", "1.5M".
  static String compact(double value) {
    final magnitude = value.abs();
    String trim(double v) {
      final fixed = v.toStringAsFixed(1);
      return fixed.endsWith('.0')
          ? fixed.substring(0, fixed.length - 2)
          : fixed;
    }

    final text = magnitude >= 1000000
        ? '${trim(magnitude / 1000000)}M'
        : magnitude >= 1000
        ? '${trim(magnitude / 1000)}k'
        : trim(magnitude);
    return value < 0 ? '$kMinus$text' : text;
  }
}

extension MoneyContext on BuildContext {
  /// The formatter for the current currency and separator setting. Call it
  /// from `build` — it rebuilds the widget when either changes.
  MoneyFormatter get money => watch<MoneyFormatter>();

  /// Same as [money], for callbacks outside `build`.
  MoneyFormatter get moneyNow => read<MoneyFormatter>();
}

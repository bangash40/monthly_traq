import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/app/money.dart';

void main() {
  const money = MoneyFormatter(symbol: 'Rs.');

  group('MoneyFormatter.format', () {
    test('groups thousands and prefixes the symbol', () {
      expect(money.format(81400), 'Rs. 81,400');
      expect(money.format(1450), 'Rs. 1,450');
      expect(money.format(850), 'Rs. 850');
      expect(money.format(0), 'Rs. 0');
    });

    test('shows two decimals only when there are cents', () {
      expect(money.format(12.5), 'Rs. 12.50');
      expect(money.format(1287.14), 'Rs. 1,287.14');
      expect(money.format(1287.0), 'Rs. 1,287');
    });

    test('rounds to cents without floating-point noise', () {
      expect(money.format(0.1 + 0.2), 'Rs. 0.30');
    });

    test('signs income, expenses and net totals', () {
      expect(money.format(120000, sign: MoneySign.income), '+Rs. 120,000');
      expect(money.format(3450, sign: MoneySign.expense), '${kMinus}Rs. 3,450');
      expect(money.format(-4300, sign: MoneySign.auto), '${kMinus}Rs. 4,300');
      expect(money.format(116550, sign: MoneySign.auto), '+Rs. 116,550');
      expect(money.format(0, sign: MoneySign.auto), 'Rs. 0');
    });

    test('uses the typographic minus, not a hyphen', () {
      expect(money.format(5, sign: MoneySign.expense), startsWith('−'));
    });

    test('can leave out the symbol', () {
      expect(
        money.format(38600, sign: MoneySign.expense, withSymbol: false),
        '${kMinus}38,600',
      );
    });

    test('no sign shows the magnitude', () {
      expect(money.format(-3500), 'Rs. 3,500');
    });

    test('respects the thousands separator setting', () {
      const plain = MoneyFormatter(symbol: '\$', grouping: false);
      expect(plain.format(120000), '\$ 120000');
      expect(plain.format(1234.5), '\$ 1234.50');
    });
  });

  group('MoneyFormatter.compact', () {
    test('shortens axis labels', () {
      expect(MoneyFormatter.compact(0), '0');
      expect(MoneyFormatter.compact(850), '850');
      expect(MoneyFormatter.compact(60000), '60k');
      expect(MoneyFormatter.compact(120000), '120k');
      expect(MoneyFormatter.compact(12500), '12.5k');
      expect(MoneyFormatter.compact(1500000), '1.5M');
    });
  });

  test('formatters with the same settings are equal', () {
    expect(const MoneyFormatter(symbol: 'Rs.'), money);
    expect(const MoneyFormatter(symbol: 'Rs.', grouping: false), isNot(money));
  });
}

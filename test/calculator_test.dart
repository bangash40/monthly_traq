import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/services/calculator.dart';

Calculator typed(String keys) {
  final calc = Calculator();
  for (final key in keys.split('')) {
    switch (key) {
      case '.':
        calc.decimal();
      case '<':
        calc.backspace();
      case '+' || '-' || '×' || '÷':
        calc.operator(key);
      default:
        calc.digit(key);
    }
  }
  return calc;
}

void main() {
  group('typing', () {
    test('starts at zero and replaces a leading zero', () {
      expect(Calculator().raw, '0');
      expect(typed('7').raw, '7');
      expect(typed('007').raw, '7');
    });

    test('allows one decimal point per number', () {
      expect(typed('12.5.0').raw, '12.50');
      expect(typed('1.5+2.25').raw, '1.5+2.25');
    });

    test('a decimal right after an operator becomes 0.', () {
      expect(typed('12+.5').raw, '12+0.5');
      expect(typed('12+.5').value, 12.5);
    });

    test('a second operator replaces the first', () {
      expect(typed('5+×3').raw, '5×3');
    });

    test('backspace removes one character, down to zero', () {
      expect(typed('123<').raw, '12');
      expect(typed('1<<').raw, '0');
    });

    test('caps each number at 12 digits', () {
      expect(typed('1234567890123456').raw, '123456789012');
    });

    test('clear resets to zero', () {
      expect((typed('45+6')..clear()).raw, '0');
    });
  });

  group('evaluate', () {
    test('adds and subtracts left to right', () {
      expect(typed('1200+250').value, 1450);
      expect(typed('100-30-20').value, 50);
    });

    test('multiplies and divides before adding', () {
      expect(typed('2+3×4').value, 14);
      expect(typed('20-12÷4').value, 17);
      expect(typed('10÷4').value, 2.5);
    });

    test('ignores a dangling operator or decimal point', () {
      expect(typed('1450+').value, 1450);
      expect(Calculator.evaluate('12.'), 12);
    });

    test('division by zero gives zero instead of throwing', () {
      expect(typed('5÷0').value, 0);
    });

    test('can go negative', () {
      expect(typed('5-10').value, -5);
    });

    test('rounds results to cents', () {
      expect(typed('.1+.2').value, 0.3);
      expect(typed('10÷3').value, 3.33);
    });
  });

  group('display', () {
    test('groups numbers and spaces operators', () {
      expect(typed('1200+250').display(), '1,200 + 250');
      expect(typed('100000-5').display(), '100,000 − 5');
    });

    test('keeps decimals exactly as typed', () {
      expect(typed('1200.50').display(), '1,200.50');
    });

    test('can skip grouping', () {
      expect(typed('1200+250').display(grouping: false), '1200 + 250');
    });

    test('trims a trailing operator', () {
      expect(typed('1450×').display(), '1,450 ×');
    });
  });

  test('plain() round-trips existing amounts for editing', () {
    expect(Calculator.plain(1450), '1450');
    expect(Calculator.plain(12.5), '12.5');
    expect(Calculator.plain(0.25), '0.25');
    expect(Calculator.fromAmount(3450).value, 3450);
  });
}

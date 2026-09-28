import 'package:intl/intl.dart';

/// The keypad's operators, as stored in the expression. Minus is the ASCII
/// hyphen; [Calculator.display] shows it as a proper "−".
const kCalculatorOperators = '+-×÷';

/// The Add screen's keypad input: digits, a decimal point and + − × ÷,
/// kept as an expression and evaluated live with the usual precedence.
class Calculator {
  static const maxDigits = 12;

  String _raw;

  Calculator([String initial = '0']) : _raw = initial.isEmpty ? '0' : initial;

  /// Starts from an existing amount, e.g. when editing a transaction.
  factory Calculator.fromAmount(double amount) => Calculator(plain(amount));

  String get raw => _raw;

  bool _isOperator(String char) => kCalculatorOperators.contains(char);

  int get _lastOperatorIndex {
    for (var i = _raw.length - 1; i >= 0; i--) {
      if (_isOperator(_raw[i])) return i;
    }
    return -1;
  }

  /// True once the expression has an operator in it, i.e. there's a
  /// calculation to show above the result.
  bool get hasOperator => _lastOperatorIndex != -1;

  String get _lastNumber => _raw.substring(_lastOperatorIndex + 1);

  bool get _endsWithOperator => _isOperator(_raw[_raw.length - 1]);

  void digit(String d) {
    final last = _lastNumber;
    if (last == '0') {
      _raw = _raw.substring(0, _raw.length - 1) + d;
    } else if (last.replaceAll('.', '').length < maxDigits) {
      _raw += d;
    }
  }

  /// Adds [op], or swaps it for the operator already at the end.
  void operator(String op) {
    assert(_isOperator(op));
    _raw = _endsWithOperator
        ? _raw.substring(0, _raw.length - 1) + op
        : _raw + op;
  }

  void decimal() {
    if (_lastNumber.contains('.')) return;
    _raw += _endsWithOperator ? '0.' : '.';
  }

  void backspace() {
    _raw = _raw.length <= 1 ? '0' : _raw.substring(0, _raw.length - 1);
  }

  void clear() => _raw = '0';

  /// The expression's result, rounded to cents.
  double get value => evaluate(_raw);

  /// Evaluates [expression] with × and ÷ before + and −. A trailing
  /// operator or decimal point is ignored, and dividing by zero gives zero,
  /// so a half-typed expression never throws.
  static double evaluate(String expression) {
    var expr = expression;
    while (expr.isNotEmpty &&
        kCalculatorOperators.contains(expr[expr.length - 1])) {
      expr = expr.substring(0, expr.length - 1);
    }
    if (expr.isEmpty) return 0;

    double parse(String number) =>
        double.tryParse(number.endsWith('.') ? '${number}0' : number) ?? 0;

    final numbers = <double>[];
    final ops = <String>[];
    var current = '';
    for (final char in expr.split('')) {
      if (kCalculatorOperators.contains(char)) {
        numbers.add(parse(current));
        ops.add(char);
        current = '';
      } else {
        current += char;
      }
    }
    numbers.add(parse(current));

    // × and ÷ first, folding each into the number before it.
    final terms = <double>[numbers.first];
    final addOps = <String>[];
    for (var i = 0; i < ops.length; i++) {
      final rhs = numbers[i + 1];
      switch (ops[i]) {
        case '×':
          terms.add(terms.removeLast() * rhs);
        case '÷':
          final lhs = terms.removeLast();
          terms.add(rhs == 0 ? 0 : lhs / rhs);
        default:
          addOps.add(ops[i]);
          terms.add(rhs);
      }
    }

    var result = terms.first;
    for (var i = 0; i < addOps.length; i++) {
      result = addOps[i] == '+' ? result + terms[i + 1] : result - terms[i + 1];
    }
    return (result * 100).round() / 100;
  }

  /// The expression for display: grouped numbers and spaced operators,
  /// "1200+250" → "1,200 + 250". Decimals stay exactly as typed.
  String display({bool grouping = true}) {
    final group = NumberFormat(grouping ? '#,##0' : '0', 'en_US');
    String formatNumber(String number) {
      if (number.isEmpty) return number;
      final parts = number.split('.');
      final whole = int.tryParse(parts[0]);
      final grouped = whole == null ? parts[0] : group.format(whole);
      return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
    }

    final buffer = StringBuffer();
    var number = '';
    for (final char in _raw.split('')) {
      if (_isOperator(char)) {
        buffer
          ..write(formatNumber(number))
          ..write(' ${char == '-' ? '−' : char} ');
        number = '';
      } else {
        number += char;
      }
    }
    buffer.write(formatNumber(number));
    return buffer.toString().trimRight();
  }

  /// [amount] as keypad input: "1450", "12.5", "0.25".
  static String plain(double amount) {
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    final fixed = amount.toStringAsFixed(2);
    return fixed.endsWith('0') ? fixed.substring(0, fixed.length - 1) : fixed;
  }
}

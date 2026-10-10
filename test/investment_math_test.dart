import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/models/investment_models.dart';
import 'package:monthly_traq/services/investment_math.dart';

const _akd = InvestAccount(id: 'akd', name: 'AKD', color: Colors.blue);

var _n = 0;
InvestEntry _e(
  InvestEntryKind kind,
  double amount,
  DateTime date, {
  String account = 'akd',
}) => InvestEntry(
  id: 'e${_n++}',
  accountId: account,
  kind: kind,
  amount: amount,
  date: date,
);

void main() {
  test('gain is value plus dividends minus what was put in', () {
    final p = InvestProgress.of(_akd, [
      _e(InvestEntryKind.deposit, 200000, DateTime(2026, 1, 1)),
      _e(InvestEntryKind.value, 245000, DateTime(2026, 6, 1)),
      _e(InvestEntryKind.dividend, 5000, DateTime(2026, 7, 1)),
    ]);
    expect(p.putIn, 200000);
    expect(p.value, 245000);
    expect(p.dividends, 5000);
    expect(p.gain, 50000);
    expect(p.gainPercent, 25);
    expect(p.valuedAt, DateTime(2026, 6, 1));
  });

  test('money put in or taken out after the last value moves the value', () {
    final p = InvestProgress.of(_akd, [
      _e(InvestEntryKind.deposit, 100000, DateTime(2026, 1, 1)),
      _e(InvestEntryKind.value, 110000, DateTime(2026, 2, 1)),
      _e(InvestEntryKind.deposit, 50000, DateTime(2026, 3, 1)),
      _e(InvestEntryKind.withdraw, 20000, DateTime(2026, 4, 1)),
    ]);
    expect(p.putIn, 130000);
    expect(p.value, 140000);
    expect(p.gain, 10000);
  });

  test('a new value replaces what came before it', () {
    final p = InvestProgress.of(_akd, [
      _e(InvestEntryKind.deposit, 100000, DateTime(2026, 1, 1)),
      _e(InvestEntryKind.deposit, 50000, DateTime(2026, 2, 1)),
      _e(InvestEntryKind.value, 120000, DateTime(2026, 3, 1)),
    ]);
    expect(p.value, 120000);
    expect(p.gain, -30000);
    expect(p.gainPercent, -20);
    expect(p.valueHistory.length, 1);
  });

  test('order comes from the dates, not the list', () {
    final p = InvestProgress.of(_akd, [
      _e(InvestEntryKind.value, 90000, DateTime(2026, 5, 1)),
      _e(InvestEntryKind.deposit, 100000, DateTime(2026, 1, 1)),
    ]);
    expect(p.value, 90000);
  });

  test('no value yet: it is worth what was put in', () {
    final p = InvestProgress.of(_akd, [
      _e(InvestEntryKind.deposit, 75000, DateTime(2026, 1, 1)),
      _e(InvestEntryKind.deposit, 1, DateTime(2026, 1, 1), account: 'js'),
    ]);
    expect(p.value, 75000);
    expect(p.gain, 0);
    expect(p.valuedAt, isNull);
  });

  test('totals add the accounts up', () {
    const js = InvestAccount(id: 'js', name: 'JS', color: Colors.red);
    final entries = [
      _e(InvestEntryKind.deposit, 200000, DateTime(2026, 1, 1)),
      _e(InvestEntryKind.value, 245000, DateTime(2026, 6, 1)),
      _e(InvestEntryKind.deposit, 50000, DateTime(2026, 1, 1), account: 'js'),
      _e(InvestEntryKind.value, 45000, DateTime(2026, 6, 1), account: 'js'),
    ];
    final t = InvestTotals.of([
      InvestProgress.of(_akd, entries),
      InvestProgress.of(js, entries),
    ]);
    expect(t.putIn, 250000);
    expect(t.value, 290000);
    expect(t.gain, 40000);
    expect(t.gainPercent, 16);
  });
}

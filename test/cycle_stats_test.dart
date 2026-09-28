import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/budget_cycle.dart';
import 'package:monthly_traq/services/cycle_stats.dart';

const food = CategoryModel(
  id: 'food',
  name: 'Food',
  icon: Icons.restaurant,
  color: Color(0xFFEB6834),
);
const shopping = CategoryModel(
  id: 'shopping',
  name: 'Shopping',
  icon: Icons.shopping_bag,
  color: Color(0xFF2A78D6),
);
const salary = CategoryModel(
  id: 'salary',
  name: 'Salary',
  icon: Icons.work,
  color: Color(0xFF2A78D6),
  type: TransactionType.income,
);

var _id = 0;
TransactionModel tx(
  double amount,
  DateTime date, {
  String? categoryId,
  TransactionType type = TransactionType.expense,
}) => TransactionModel(
  id: '${_id++}',
  title: '',
  amount: amount,
  type: type,
  categoryId: categoryId,
  date: date,
);

void main() {
  final sep = BudgetCycle.startingIn(2026, 9, 1);
  final stats = CycleStats([
    tx(
      120000,
      DateTime(2026, 9, 1, 9),
      categoryId: 'salary',
      type: TransactionType.income,
    ),
    tx(3450, DateTime(2026, 9, 16, 19), categoryId: 'food'),
    tx(1600, DateTime(2026, 9, 16, 21), categoryId: 'food'),
    tx(12400, DateTime(2026, 9, 10), categoryId: 'shopping'),
    tx(700, DateTime(2026, 9, 3), categoryId: 'deleted-category'),
    tx(900, DateTime(2026, 9, 4)), // no category at all
    tx(5000, DateTime(2026, 8, 20), categoryId: 'food'), // previous month
    tx(2000, DateTime(2026, 10, 1), categoryId: 'food'), // next month
  ]);

  test('totals only count the cycle and type', () {
    expect(
      stats.total(TransactionType.expense, sep),
      3450 + 1600 + 12400 + 700 + 900,
    );
    expect(stats.total(TransactionType.income, sep), 120000);
    expect(stats.total(TransactionType.expense, sep.previous), 5000);
  });

  test('totals can be narrowed to one category', () {
    expect(stats.total(TransactionType.expense, sep, categoryId: 'food'), 5050);
    expect(
      stats.total(TransactionType.expense, sep, categoryId: kUncategorizedId),
      900,
    );
  });

  test('byCategory is largest first and keeps orphans as Uncategorized', () {
    final rows = stats.byCategory(TransactionType.expense, sep, [
      food,
      shopping,
      salary,
    ]);
    expect(rows.map((r) => r.category.name), [
      'Shopping',
      'Food',
      'Uncategorized',
    ]);
    expect(rows.map((r) => r.amount), [12400, 5050, 1600]);
    expect(rows.map((r) => r.count), [1, 2, 2]);
    // Nothing goes missing: the rows add up to the cycle total.
    expect(
      rows.fold(0.0, (sum, r) => sum + r.amount),
      stats.total(TransactionType.expense, sep),
    );
  });

  test('daily totals cover every day and add up', () {
    final days = stats.daily(TransactionType.expense, sep);
    expect(days, hasLength(30));
    expect(days[15].day, DateTime(2026, 9, 16));
    expect(days[15].amount, 5050);
    expect(days[0].amount, 0);
  });

  test('biggest day', () {
    final biggest = stats.biggestDay(TransactionType.expense, sep)!;
    expect(biggest.day, DateTime(2026, 9, 10));
    expect(biggest.amount, 12400);
    expect(stats.biggestDay(TransactionType.expense, sep.shift(-3)), isNull);
  });

  test('daily average uses the days so far, then the whole cycle', () {
    final total = stats.total(TransactionType.expense, sep);
    expect(
      stats.dailyAverage(
        TransactionType.expense,
        sep,
        DateTime(2026, 9, 10, 12),
      ),
      total / 10,
    );
    expect(
      stats.dailyAverage(TransactionType.expense, sep, DateTime(2026, 11, 1)),
      total / 30,
    );
  });

  test('trend lists six cycles, oldest first, ending with the given one', () {
    final trend = stats.trend(sep);
    expect(trend, hasLength(6));
    expect(trend.first.month, DateTime(2026, 4, 1));
    expect(trend.last.month, DateTime(2026, 9, 1));
    expect(trend.last.income, 120000);
    expect(trend[4].expense, 5000);
  });

  test('percentChange', () {
    expect(percentChange(88, 100), closeTo(-12, 0.001));
    expect(percentChange(150, 100), closeTo(50, 0.001));
    expect(percentChange(100, 0), isNull);
  });
}

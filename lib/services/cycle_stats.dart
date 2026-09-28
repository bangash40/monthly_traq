import 'package:flutter/material.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/monthly_total.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/budget_cycle.dart';

/// Stands in for transactions whose category was deleted, so their money
/// still shows up in breakdowns instead of silently going missing.
const kUncategorizedId = '';

CategoryModel uncategorized(TransactionType type) => CategoryModel(
  id: kUncategorizedId,
  name: 'Uncategorized',
  icon: Icons.category,
  color: AppPalette.uncategorized,
  type: type,
);

/// One row of a spending (or income) breakdown.
class CategoryTotal {
  final CategoryModel category;
  final double amount;
  final int count;

  const CategoryTotal(this.category, this.amount, this.count);
}

/// The busiest day of a cycle.
class DayTotal {
  final DateTime day;
  final double amount;

  const DayTotal(this.day, this.amount);
}

/// Pure calculations over a list of transactions — no Firebase, so they
/// can be unit-tested directly.
class CycleStats {
  final List<TransactionModel> transactions;

  const CycleStats(this.transactions);

  Iterable<TransactionModel> _matching(
    TransactionType type,
    BudgetCycle cycle, {
    String? categoryId,
  }) => transactions.where(
    (t) =>
        t.type == type &&
        cycle.contains(t.date) &&
        (categoryId == null ||
            (t.categoryId ?? kUncategorizedId) == categoryId),
  );

  double total(TransactionType type, BudgetCycle cycle, {String? categoryId}) =>
      _matching(
        type,
        cycle,
        categoryId: categoryId,
      ).fold(0.0, (sum, t) => sum + t.amount);

  /// Totals per category, largest first. [categories] resolves ids; an id
  /// that's gone is grouped under "Uncategorized".
  List<CategoryTotal> byCategory(
    TransactionType type,
    BudgetCycle cycle,
    List<CategoryModel> categories,
  ) {
    final amounts = <String, double>{};
    final counts = <String, int>{};
    final known = {for (final c in categories) c.id: c};

    for (final t in _matching(type, cycle)) {
      final id = known.containsKey(t.categoryId)
          ? t.categoryId!
          : kUncategorizedId;
      amounts[id] = (amounts[id] ?? 0) + t.amount;
      counts[id] = (counts[id] ?? 0) + 1;
    }

    final rows = [
      for (final entry in amounts.entries)
        CategoryTotal(
          known[entry.key] ?? uncategorized(type),
          entry.value,
          counts[entry.key]!,
        ),
    ];
    rows.sort((a, b) => b.amount.compareTo(a.amount));
    return rows;
  }

  /// The total for each day of [cycle], in order — zero for quiet days.
  List<DayTotal> daily(
    TransactionType type,
    BudgetCycle cycle, {
    String? categoryId,
  }) {
    final byDay = <DateTime, double>{};
    for (final t in _matching(type, cycle, categoryId: categoryId)) {
      final day = DateUtils.dateOnly(t.date);
      byDay[day] = (byDay[day] ?? 0) + t.amount;
    }
    return [for (final day in cycle.days) DayTotal(day, byDay[day] ?? 0)];
  }

  /// The day with the most money moved, or null if there was none.
  DayTotal? biggestDay(TransactionType type, BudgetCycle cycle) {
    DayTotal? best;
    for (final day in daily(type, cycle)) {
      if (day.amount > 0 && (best == null || day.amount > best.amount)) {
        best = day;
      }
    }
    return best;
  }

  /// Average per day over the days that have happened so far (the whole
  /// cycle once it's over).
  double dailyAverage(TransactionType type, BudgetCycle cycle, DateTime now) {
    final days = cycle.daysElapsed(now);
    return days == 0 ? 0 : total(type, cycle) / days;
  }

  /// Income and spending for [count] cycles ending with [last], oldest
  /// first.
  List<MonthlyTotal> trend(BudgetCycle last, {int count = 6}) {
    final totals = <MonthlyTotal>[];
    for (var i = count - 1; i >= 0; i--) {
      final cycle = last.shift(-i);
      totals.add(
        MonthlyTotal(
          month: cycle.start,
          income: total(TransactionType.income, cycle),
          expense: total(TransactionType.expense, cycle),
        ),
      );
    }
    return totals;
  }
}

/// Percent change from [previous] to [current], or null when there's
/// nothing to compare against.
double? percentChange(double current, double previous) {
  if (previous <= 0) return null;
  return (current - previous) / previous * 100;
}

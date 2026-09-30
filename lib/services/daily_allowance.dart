import 'package:flutter/material.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/budget_cycle.dart';

/// How much can be spent each remaining day of the cycle and still stay
/// on budget.
///
/// Today's allowance is worked out from what was left *before* today, so it
/// stays put while you spend today and "left today" counts down against it.
/// Spending more today lowers tomorrow's allowance, and spending less
/// raises it.
class DailyAllowance {
  /// What can be spent each day from today to the end of the cycle, in
  /// whole units.
  final double perDay;

  final double spentToday;

  /// Days left in the cycle, today included.
  final int daysLeft;

  /// Nothing was left of the budget even before today.
  final bool budgetUsedUp;

  const DailyAllowance({
    required this.perDay,
    required this.spentToday,
    required this.daysLeft,
    required this.budgetUsedUp,
  });

  double get leftToday => perDay - spentToday;
  bool get isOverToday => spentToday > perDay;

  /// Null when there's no budget or [cycle] has already ended.
  static DailyAllowance? compute({
    required double budget,
    required List<TransactionModel> transactions,
    required BudgetCycle cycle,
    required DateTime now,
  }) {
    if (budget <= 0) return null;
    final daysLeft = cycle.daysLeft(now);
    if (daysLeft <= 0) return null;

    var spentInCycle = 0.0;
    var spentToday = 0.0;
    for (final t in transactions) {
      if (t.type != TransactionType.expense || !cycle.contains(t.date)) {
        continue;
      }
      spentInCycle += t.amount;
      if (DateUtils.isSameDay(t.date, now)) spentToday += t.amount;
    }

    final leftBeforeToday = budget - (spentInCycle - spentToday);
    final perDay = leftBeforeToday > 0
        ? (leftBeforeToday / daysLeft).floorToDouble()
        : 0.0;
    return DailyAllowance(
      perDay: perDay,
      spentToday: spentToday,
      daysLeft: daysLeft,
      budgetUsedUp: leftBeforeToday <= 0,
    );
  }
}

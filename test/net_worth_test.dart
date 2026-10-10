import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/models/goal_models.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/services/net_worth.dart';

GoalModel _goal(String id, {DateTime? doneAt}) => GoalModel(
  id: id,
  name: id,
  icon: Icons.savings,
  color: Colors.blue,
  target: 100000,
  savedBefore: 30000,
  doneAt: doneAt,
  createdAt: DateTime(2026, 1, 1),
);

var _n = 0;
GoalEntry _entry(
  String goal,
  GoalEntryKind kind,
  double amount,
  PaymentSource source,
) => GoalEntry(
  id: 'e${_n++}',
  goalId: goal,
  kind: kind,
  amount: amount,
  date: DateTime(2026, 2, 1),
  source: source,
);

void main() {
  test('goals count only money moved in, never saved-before or recorded', () {
    final counted = goalMoneyCounted(
      [_goal('mobile'), _goal('bike', doneAt: DateTime(2026, 5, 1))],
      [
        _entry('mobile', GoalEntryKind.add, 10000, PaymentSource.budget),
        _entry('mobile', GoalEntryKind.add, 5000, PaymentSource.wallet),
        _entry('mobile', GoalEntryKind.add, 8000, PaymentSource.none),
        _entry('mobile', GoalEntryKind.takeOut, 3000, PaymentSource.wallet),
        // Done: the money was spent on the bike.
        _entry('bike', GoalEntryKind.add, 50000, PaymentSource.budget),
      ],
    );
    expect(counted, 12000);
  });

  test('taking out more than was moved in never goes below zero', () {
    final counted = goalMoneyCounted(
      [_goal('mobile')],
      [_entry('mobile', GoalEntryKind.takeOut, 3000, PaymentSource.none)],
    );
    expect(counted, 0);
  });

  test('net worth is what is owned minus what is owed, skipping parts off', () {
    final amounts = {
      NetWorthPart.wallets: 50000.0,
      NetWorthPart.goals: 30000.0,
      NetWorthPart.investments: 245000.0,
      NetWorthPart.balance: 382830.0,
      NetWorthPart.repayments: 90000.0,
    };
    expect(netWorthOf(amounts, {NetWorthPart.balance}), 235000);
    expect(
      netWorthOf(amounts, {NetWorthPart.balance, NetWorthPart.repayments}),
      325000,
    );
    expect(netWorthOf(amounts, {}), 617830);
  });
}

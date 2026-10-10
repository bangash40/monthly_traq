import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/models/goal_models.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/services/goal_progress.dart';

GoalModel _goal({
  double target = 150000,
  double savedBefore = 0,
  DateTime? targetDate,
  DateTime? createdAt,
}) => GoalModel(
  id: 'mobile',
  name: 'New mobile',
  icon: Icons.smartphone,
  color: Colors.blue,
  target: target,
  savedBefore: savedBefore,
  targetDate: targetDate,
  createdAt: createdAt ?? DateTime(2026, 1, 1),
);

var _n = 0;
GoalEntry _entry(GoalEntryKind kind, double amount, {String goal = 'mobile'}) =>
    GoalEntry(
      id: 'e${_n++}',
      goalId: goal,
      kind: kind,
      amount: amount,
      date: DateTime(2026, 2, 1),
      source: PaymentSource.none,
    );

void main() {
  test('saved is what was there before, plus added, minus taken out', () {
    final p = GoalProgress.of(_goal(savedBefore: 20000), [
      _entry(GoalEntryKind.add, 50000),
      _entry(GoalEntryKind.takeOut, 10000),
      _entry(GoalEntryKind.add, 99999, goal: 'bike'),
    ]);
    expect(p.saved, 60000);
    expect(p.remaining, 90000);
    expect(p.fraction, 0.4);
    expect(p.isReached, isFalse);
  });

  test('reaching the target', () {
    final p = GoalProgress.of(_goal(target: 1000), [
      _entry(GoalEntryKind.add, 1200),
    ]);
    expect(p.isReached, isTrue);
    expect(p.remaining, 0);
    expect(p.fraction, 1);
    expect(p.status(DateTime(2026, 2, 1)), GoalStatus.reached);
  });

  test('per month spreads what is left over the months to the date', () {
    final p = GoalProgress.of(
      _goal(targetDate: DateTime(2026, 7, 1), savedBefore: 60000),
      [],
    );
    // 1 Jan → 1 Jul is 181 days, about 6 months.
    expect(p.monthsLeft(DateTime(2026, 1, 1)), 6);
    expect(p.perMonth(DateTime(2026, 1, 1)), 15000);
  });

  test('a date this month still counts as one month', () {
    final p = GoalProgress.of(_goal(targetDate: DateTime(2026, 1, 20)), []);
    expect(p.monthsLeft(DateTime(2026, 1, 10)), 1);
    expect(p.perMonth(DateTime(2026, 1, 10)), 150000);
  });

  test('on track or behind against an even pace from the start', () {
    final goal = _goal(
      target: 120000,
      targetDate: DateTime(2026, 12, 31),
      createdAt: DateTime(2026, 1, 1),
    );
    final halfway = DateTime(2026, 7, 2);
    expect(
      GoalProgress.of(goal, [_entry(GoalEntryKind.add, 60000)]).status(halfway),
      GoalStatus.onTrack,
    );
    expect(
      GoalProgress.of(goal, [_entry(GoalEntryKind.add, 40000)]).status(halfway),
      GoalStatus.behind,
    );
  });

  test('a passed date, or none at all', () {
    final late = GoalProgress.of(_goal(targetDate: DateTime(2026, 3, 1)), []);
    expect(late.status(DateTime(2026, 3, 2)), GoalStatus.overdue);
    expect(late.perMonth(DateTime(2026, 3, 2)), isNull);

    final open = GoalProgress.of(_goal(), []);
    expect(open.status(DateTime(2026, 3, 2)), GoalStatus.noDate);
    expect(open.perMonth(DateTime(2026, 3, 2)), isNull);
  });

  test('taking out more than saved never goes below zero', () {
    final p = GoalProgress.of(_goal(), [_entry(GoalEntryKind.takeOut, 500)]);
    expect(p.saved, 0);
  });
}

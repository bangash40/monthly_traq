import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/budget_cycle.dart';
import 'package:monthly_traq/services/budget_win.dart';
import 'package:monthly_traq/widgets/motion.dart';

void main() {
  group('BudgetWin', () {
    // October's cycle; September is the one being celebrated.
    final october = BudgetCycle.containing(DateTime(2026, 10, 3), 1);
    var id = 0;
    TransactionModel spend(double amount, DateTime date) => TransactionModel(
      id: '${id++}',
      title: 'x',
      amount: amount,
      type: TransactionType.expense,
      date: date,
    );

    BudgetWin? win(
      double budget,
      List<TransactionModel> txs, {
      DateTime? now,
    }) => BudgetWin.forPreviousCycle(
      budget: budget,
      transactions: txs,
      current: october,
      now: now ?? DateTime(2026, 10, 3),
    );

    test('celebrates a month that ended under budget', () {
      final w = win(60000, [
        spend(40000, DateTime(2026, 9, 10)),
        spend(6530, DateTime(2026, 9, 28)),
      ])!;
      expect(w.cycle.start, DateTime(2026, 9, 1));
      expect(w.spent, 46530);
      expect(w.leftOver, 13470);
    });

    test('nothing when over budget', () {
      expect(win(10000, [spend(12000, DateTime(2026, 9, 5))]), isNull);
    });

    test('exactly on budget still counts', () {
      expect(win(10000, [spend(10000, DateTime(2026, 9, 5))]), isNotNull);
    });

    test('nothing without a budget', () {
      expect(win(0, [spend(100, DateTime(2026, 9, 5))]), isNull);
    });

    test('nothing when last month had no spending logged', () {
      expect(win(60000, [spend(500, DateTime(2026, 10, 2))]), isNull);
    });

    test('only shows for the first week of the new cycle', () {
      final txs = [spend(500, DateTime(2026, 9, 5))];
      expect(win(60000, txs, now: DateTime(2026, 10, 7)), isNotNull);
      expect(win(60000, txs, now: DateTime(2026, 10, 8)), isNull);
    });

    test('ignores income', () {
      final salary = TransactionModel(
        id: 'salary',
        title: 'Salary',
        amount: 100000,
        type: TransactionType.income,
        date: DateTime(2026, 9, 1),
      );
      expect(win(60000, [salary]), isNull);
    });

    test('ids differ per cycle', () {
      final txs = [spend(500, DateTime(2026, 9, 5))];
      expect(win(60000, txs)!.id, '2026-9-1');
    });
  });

  group('AppSettings', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('haptic feedback starts on and can be turned off', () async {
      final settings = AppSettings(load: false);
      expect(settings.hapticFeedback, isTrue);
      await settings.setHapticFeedback(false);
      expect(settings.hapticFeedback, isFalse);
    });

    test('a dismissed celebration is remembered', () async {
      final settings = AppSettings(load: false);
      expect(settings.dismissedBudgetWin, isNull);
      await settings.dismissBudgetWin('2026-9-1');
      expect(settings.dismissedBudgetWin, '2026-9-1');
    });
  });

  group('CountUp', () {
    Widget host(double value) => MaterialApp(
      home: CountUp(
        value: value,
        builder: (context, v) => Text(v.toStringAsFixed(2)),
      ),
    );

    testWidgets('counts from zero and lands on the value', (tester) async {
      await tester.pumpWidget(host(4330));
      expect(find.text('0.00'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      final midway = double.parse(
        (tester.widget(find.byType(Text)) as Text).data!,
      );
      expect(midway, greaterThan(0));
      expect(midway, lessThan(4330));
      expect(midway, midway.roundToDouble(), reason: 'whole steps only');
      await tester.pumpAndSettle();
      expect(find.text('4330.00'), findsOneWidget);
    });

    testWidgets('counts up again each time its tab is opened', (tester) async {
      Widget tab(int visit) => MaterialApp(
        home: TabVisit(
          visit: visit,
          child: CountUp(
            value: 4330,
            builder: (context, v) => Text(v.toStringAsFixed(2)),
          ),
        ),
      );
      await tester.pumpWidget(tab(0));
      await tester.pumpAndSettle();
      expect(find.text('4330.00'), findsOneWidget);

      await tester.pumpWidget(tab(1));
      expect(find.text('0.00'), findsOneWidget, reason: 'restarted');
      await tester.pumpAndSettle();
      expect(find.text('4330.00'), findsOneWidget);
    });

    testWidgets('shows the value at once when animations are off', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: host(4330),
        ),
      );
      await tester.pump();
      expect(find.text('4330.00'), findsOneWidget);
    });
  });
}

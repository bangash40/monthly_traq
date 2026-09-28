import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/services/budget_cycle.dart';

void main() {
  group('BudgetCycle.containing', () {
    test('start day 1 is the calendar month', () {
      final cycle = BudgetCycle.containing(DateTime(2026, 9, 18, 14, 30), 1);
      expect(cycle.start, DateTime(2026, 9, 1));
      expect(cycle.end, DateTime(2026, 10, 1));
      expect(cycle.lengthInDays, 30);
    });

    test('a custom start day spans two calendar months', () {
      final cycle = BudgetCycle.containing(DateTime(2026, 10, 3), 25);
      expect(cycle.start, DateTime(2026, 9, 25));
      expect(cycle.end, DateTime(2026, 10, 25));
      expect(cycle.lastDay, DateTime(2026, 10, 24));
    });

    test('the start day itself belongs to the new cycle', () {
      final cycle = BudgetCycle.containing(DateTime(2026, 9, 25), 25);
      expect(cycle.start, DateTime(2026, 9, 25));
    });

    test('rolls back across the year boundary', () {
      final cycle = BudgetCycle.containing(DateTime(2027, 1, 10), 25);
      expect(cycle.start, DateTime(2026, 12, 25));
      expect(cycle.end, DateTime(2027, 1, 25));
    });
  });

  group('start days past the end of a month', () {
    test('31 falls back to the last day of shorter months', () {
      expect(BudgetCycle.dayOfMonth(2026, 2, 31), DateTime(2026, 2, 28));
      expect(BudgetCycle.dayOfMonth(2028, 2, 31), DateTime(2028, 2, 29));
      expect(BudgetCycle.dayOfMonth(2026, 4, 31), DateTime(2026, 4, 30));
    });

    test('catches back up to the 31st in long months', () {
      final jan = BudgetCycle.startingIn(2026, 1, 31);
      expect(jan.start, DateTime(2026, 1, 31));
      expect(jan.end, DateTime(2026, 2, 28));
      final feb = jan.shift(1);
      expect(feb.start, DateTime(2026, 2, 28));
      expect(feb.end, DateTime(2026, 3, 31));
    });
  });

  group('navigation', () {
    test('shift moves whole cycles, across years', () {
      final sep = BudgetCycle.startingIn(2026, 9, 1);
      expect(sep.previous.start, DateTime(2026, 8, 1));
      expect(sep.shift(-9).start, DateTime(2025, 12, 1));
      expect(sep.shift(4).start, DateTime(2027, 1, 1));
    });

    test('contains is start-inclusive and end-exclusive', () {
      final sep = BudgetCycle.startingIn(2026, 9, 1);
      expect(sep.contains(DateTime(2026, 9, 1)), isTrue);
      expect(sep.contains(DateTime(2026, 9, 30, 23, 59)), isTrue);
      expect(sep.contains(DateTime(2026, 10, 1)), isFalse);
      expect(sep.contains(DateTime(2026, 8, 31, 23, 59)), isFalse);
    });
  });

  group('days', () {
    final sep = BudgetCycle.startingIn(2026, 9, 1);

    test('daysLeft counts today', () {
      expect(sep.daysLeft(DateTime(2026, 9, 27, 20)), 4);
      expect(sep.daysLeft(DateTime(2026, 9, 30, 8)), 1);
      expect(sep.daysLeft(DateTime(2026, 10, 2)), 0);
      expect(sep.daysLeft(DateTime(2026, 8, 20)), 30);
    });

    test('daysElapsed counts today', () {
      expect(sep.daysElapsed(DateTime(2026, 9, 1, 9)), 1);
      expect(sep.daysElapsed(DateTime(2026, 9, 28)), 28);
      expect(sep.daysElapsed(DateTime(2026, 11, 5)), 30);
      expect(sep.daysElapsed(DateTime(2026, 8, 5)), 0);
    });

    test('lists every day', () {
      expect(sep.days, hasLength(30));
      expect(sep.days.first, DateTime(2026, 9, 1));
      expect(sep.days.last, DateTime(2026, 9, 30));
    });
  });

  group('labels', () {
    test('calendar months read as month names', () {
      final sep = BudgetCycle.startingIn(2026, 9, 1);
      expect(sep.title, 'September 2026');
      expect(sep.shortTitle, 'September');
      expect(sep.monthAbbreviation, 'Sep');
      expect(sep.rangeLabel, 'Sep 1 – 30');
    });

    test('custom cycles read as ranges', () {
      final cycle = BudgetCycle.startingIn(2026, 9, 25);
      expect(cycle.title, 'Sep 25 – Oct 24, 2026');
      expect(cycle.shortTitle, 'Sep 25 – Oct 24');
      expect(cycle.rangeLabel, 'Sep 25 – Oct 24');
    });

    test('ranges spanning new year show both years', () {
      final cycle = BudgetCycle.startingIn(2026, 12, 25);
      expect(cycle.title, 'Dec 25, 2026 – Jan 24, 2027');
    });
  });

  test('ordinal suffixes', () {
    expect([1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 31].map(ordinal).toList(), [
      '1st',
      '2nd',
      '3rd',
      '4th',
      '11th',
      '12th',
      '13th',
      '21st',
      '22nd',
      '23rd',
      '31st',
    ]);
  });
}

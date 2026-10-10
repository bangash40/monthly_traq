import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_traq/models/repayment_models.dart';
import 'package:monthly_traq/services/repayment_schedule.dart';
import 'package:monthly_traq/l10n/app_localizations.dart';

RepaymentModel _repayment({
  double total = 271200,
  double paidBefore = 0,
  RepaymentFrequency frequency = RepaymentFrequency.monthly,
  int everyMonths = 1,
  double? installment = 11300,
  DateTime? nextDue,
  int? anchorDay,
}) => RepaymentModel(
  id: 'bike',
  name: 'Bike installment',
  total: total,
  paidBefore: paidBefore,
  frequency: frequency,
  everyMonths: everyMonths,
  installment: installment,
  nextDue: nextDue ?? DateTime(2026, 10, 5),
  anchorDay: anchorDay ?? (nextDue ?? DateTime(2026, 10, 5)).day,
);

RepaymentPayment _paid(double amount, {String id = 'bike'}) => RepaymentPayment(
  id: 'p$amount',
  repaymentId: id,
  amount: amount,
  date: DateTime(2026, 10, 5),
  source: PaymentSource.none,
);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  group('due dates', () {
    test('monthly keeps its day, and the 31st falls back in short months', () {
      final r = _repayment(nextDue: DateTime(2026, 1, 31));
      final feb = nextDueAfter(r, DateTime(2026, 1, 31));
      expect(feb, DateTime(2026, 2, 28));
      expect(nextDueAfter(r, feb), DateTime(2026, 3, 31));
    });

    test('daily, every few months and yearly', () {
      final due = DateTime(2026, 12, 31);
      expect(
        nextDueAfter(_repayment(frequency: RepaymentFrequency.daily), due),
        DateTime(2027, 1, 1),
      );
      expect(
        nextDueAfter(
          _repayment(
            frequency: RepaymentFrequency.everyMonths,
            everyMonths: 3,
            nextDue: due,
          ),
          due,
        ),
        DateTime(2027, 3, 31),
      );
      expect(
        nextDueAfter(
          _repayment(frequency: RepaymentFrequency.yearly, nextDue: due),
          due,
        ),
        DateTime(2027, 12, 31),
      );
    });

    test('labels', () {
      expect(dueLabel(en, 0), 'Due today');
      expect(dueLabel(en, 1), 'Due tomorrow');
      expect(dueLabel(en, 5), 'Due in 5 days');
      expect(dueLabel(en, -1), 'Overdue 1 day');
      expect(dueLabel(en, -3), 'Overdue 3 days');
    });
  });

  group('progress', () {
    test('paid counts what was paid before plus the payments', () {
      final r = _repayment(paidBefore: 11300 * 11);
      final p = RepaymentProgress.of(r, [_paid(11300), _paid(500, id: 'x')]);
      expect(p.paid, 11300 * 12);
      expect(p.remaining, 11300 * 12);
      expect(p.installmentCount, 24);
      expect(p.installmentsPaid, 12);
      expect(p.installmentsLeft, 12);
      expect(p.fraction, 0.5);
    });

    test('finish date is the last of the installments left', () {
      final r = _repayment(total: 33900, nextDue: DateTime(2026, 11, 5));
      final p = RepaymentProgress.of(r, []);
      expect(p.installmentsLeft, 3);
      expect(p.finishDate, DateTime(2027, 1, 5));
    });

    test('paid off', () {
      final r = _repayment(total: 20000, installment: 10000);
      final p = RepaymentProgress.of(r, [_paid(10000), _paid(10000.001)]);
      expect(p.isPaidOff, isTrue);
      expect(p.remaining, 0);
      expect(p.daysUntilDue(DateTime(2026, 10, 5)), isNull);
      expect(p.dueThisMonth(DateTime(2026, 10, 5)), 0);
    });

    test('days until due counts whole days', () {
      final r = _repayment(nextDue: DateTime(2026, 10, 5));
      final p = RepaymentProgress.of(r, []);
      expect(p.daysUntilDue(DateTime(2026, 10, 5, 23, 59)), 0);
      expect(p.daysUntilDue(DateTime(2026, 10, 2)), 3);
      expect(p.daysUntilDue(DateTime(2026, 10, 7)), -2);
    });

    test(
      'due this month includes overdue and repeats, capped at what is left',
      () {
        final monthly = _repayment(nextDue: DateTime(2026, 9, 25));
        // Sep 25 (overdue) and Oct 25 both fall before November.
        expect(
          RepaymentProgress.of(
            monthly,
            [],
          ).dueThisMonth(DateTime(2026, 10, 10)),
          22600,
        );

        final daily = _repayment(
          frequency: RepaymentFrequency.daily,
          installment: 100,
          total: 1000,
          nextDue: DateTime(2026, 10, 20),
        );
        // Oct 20–31 is 12 days, but only 1,000 is left.
        expect(
          RepaymentProgress.of(daily, []).dueThisMonth(DateTime(2026, 10, 10)),
          1000,
        );
      },
    );

    test('no deadline has nothing due and no finish date', () {
      final r = RepaymentModel(
        id: 'loan',
        name: 'Loan from Ali',
        total: 50000,
        frequency: RepaymentFrequency.none,
      );
      final p = RepaymentProgress.of(r, []);
      expect(p.daysUntilDue(DateTime(2026, 10, 10)), isNull);
      expect(p.finishDate, isNull);
      expect(p.dueThisMonth(DateTime(2026, 10, 10)), 0);
      expect(p.installmentCount, isNull);
      expect(p.remaining, 50000);
    });
  });
}

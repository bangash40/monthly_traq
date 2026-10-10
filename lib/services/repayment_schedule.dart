import 'package:monthly_traq/models/repayment_models.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// [date] moved [months] months on, landing on [anchorDay] (or the month's
/// last day when it's shorter).
DateTime addMonths(DateTime date, int months, int anchorDay) {
  final firstOfMonth = DateTime(date.year, date.month + months, 1);
  final lastDay = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0).day;
  return DateTime(
    firstOfMonth.year,
    firstOfMonth.month,
    anchorDay < lastDay ? anchorDay : lastDay,
  );
}

/// The due date after [due] for [repayment]'s schedule. Unchanged for
/// repayments without one.
DateTime nextDueAfter(RepaymentModel repayment, DateTime due) {
  final anchor = repayment.anchorDay ?? due.day;
  return switch (repayment.frequency) {
    RepaymentFrequency.daily => DateTime(due.year, due.month, due.day + 1),
    RepaymentFrequency.monthly => addMonths(due, 1, anchor),
    RepaymentFrequency.everyMonths => addMonths(
      due,
      repayment.everyMonths < 1 ? 1 : repayment.everyMonths,
      anchor,
    ),
    RepaymentFrequency.yearly => addMonths(due, 12, anchor),
    RepaymentFrequency.none => due,
  };
}

/// Where a repayment stands: paid, left, when it's due, when it'll be done.
class RepaymentProgress {
  final RepaymentModel repayment;

  /// Everything paid, including [RepaymentModel.paidBefore].
  final double paid;

  const RepaymentProgress._(this.repayment, this.paid);

  factory RepaymentProgress.of(
    RepaymentModel repayment,
    Iterable<RepaymentPayment> payments,
  ) {
    var paid = repayment.paidBefore;
    for (final p in payments) {
      if (p.repaymentId == repayment.id) paid += p.amount;
    }
    return RepaymentProgress._(repayment, paid);
  }

  double get remaining {
    final left = repayment.total - paid;
    return left > 0.005 ? left : 0;
  }

  bool get isPaidOff => remaining <= 0;

  /// 0–1, for progress bars.
  double get fraction {
    if (repayment.total <= 0) return 1;
    final f = paid / repayment.total;
    return f < 0 ? 0 : (f > 1 ? 1 : f);
  }

  double? get _installment {
    final i = repayment.installment;
    return i != null && i > 0 ? i : null;
  }

  /// How many installments the whole repayment takes, and how many are
  /// paid ("12 of 24"). Null without an installment amount.
  int? get installmentCount {
    final i = _installment;
    return i == null ? null : (repayment.total / i - 0.0001).ceil();
  }

  int? get installmentsPaid {
    final i = _installment;
    return i == null ? null : (paid / i + 0.0001).floor();
  }

  int? get installmentsLeft {
    final i = _installment;
    if (i == null) return null;
    return (remaining / i - 0.0001).ceil();
  }

  /// Roughly when the last payment is due, if payments keep to schedule.
  DateTime? get finishDate {
    final left = installmentsLeft;
    var due = repayment.nextDue;
    if (isPaidOff || !repayment.hasSchedule || left == null || due == null) {
      return null;
    }
    for (var i = 1; i < left && i < 5000; i++) {
      due = nextDueAfter(repayment, due!);
    }
    return due;
  }

  /// Days from [today] to the next due date: negative when overdue, 0 when
  /// due today. Null without a schedule or once paid off.
  int? daysUntilDue(DateTime today) {
    final due = repayment.nextDue;
    if (isPaidOff || !repayment.hasSchedule || due == null) return null;
    return _dateOnly(due).difference(_dateOnly(today)).inDays;
  }

  /// What falls due from now to the end of [today]'s month, overdue
  /// payments included, never more than what's left.
  double dueThisMonth(DateTime today) {
    final i = _installment;
    var due = repayment.nextDue;
    if (isPaidOff || !repayment.hasSchedule || i == null || due == null) {
      return 0;
    }
    final monthEnd = DateTime(today.year, today.month + 1, 1);
    var total = 0.0;
    for (var n = 0; n < 400 && due!.isBefore(monthEnd); n++) {
      total += i;
      due = nextDueAfter(repayment, due);
    }
    return total < remaining ? total : remaining;
  }
}

/// "Due today", "Due tomorrow", "Due in 3 days", "Overdue 2 days".
String dueLabel(int days) => switch (days) {
  0 => 'Due today',
  1 => 'Due tomorrow',
  -1 => 'Overdue 1 day',
  < 0 => 'Overdue ${-days} days',
  _ => 'Due in $days days',
};

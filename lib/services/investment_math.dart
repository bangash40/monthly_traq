import 'package:monthly_traq/models/investment_models.dart';

/// Where an investment account stands: what's been put in, what it's
/// worth, and the gain.
///
/// The value is the last one copied from the broker's app, plus money put
/// in and minus money taken out since then (that money sits in the account
/// as cash until the next update shows what it's worth).
class InvestProgress {
  final InvestAccount account;

  /// Money put in minus money taken out.
  final double putIn;
  final double value;
  final double dividends;

  /// When the value was last copied in; null if it never was.
  final DateTime? valuedAt;

  /// Every value copied in, oldest first, for the history line.
  final List<InvestEntry> valueHistory;

  const InvestProgress._({
    required this.account,
    required this.putIn,
    required this.value,
    required this.dividends,
    required this.valuedAt,
    required this.valueHistory,
  });

  factory InvestProgress.of(
    InvestAccount account,
    Iterable<InvestEntry> allEntries,
  ) {
    final entries = [
      for (final e in allEntries)
        if (e.accountId == account.id) e,
    ]..sort((a, b) => a.date.compareTo(b.date));
    var putIn = 0.0;
    var dividends = 0.0;
    double? lastValue;
    DateTime? valuedAt;
    // Deposits and withdrawals since the last value update.
    var sinceValue = 0.0;
    final history = <InvestEntry>[];
    for (final e in entries) {
      switch (e.kind) {
        case InvestEntryKind.deposit:
          putIn += e.amount;
          sinceValue += e.amount;
        case InvestEntryKind.withdraw:
          putIn -= e.amount;
          sinceValue -= e.amount;
        case InvestEntryKind.dividend:
          dividends += e.amount;
        case InvestEntryKind.value:
          lastValue = e.amount;
          valuedAt = e.date;
          sinceValue = 0;
          history.add(e);
      }
    }
    final value = (lastValue ?? 0) + sinceValue;
    return InvestProgress._(
      account: account,
      putIn: putIn,
      value: value < 0 ? 0 : value,
      dividends: dividends,
      valuedAt: valuedAt,
      valueHistory: history,
    );
  }

  /// What the investing has made: the value plus dividends, minus what was
  /// put in.
  double get gain => value + dividends - putIn;

  /// [gain] as a share of what was put in; null when nothing was put in.
  double? get gainPercent => putIn > 0 ? gain / putIn * 100 : null;
}

/// All accounts together.
class InvestTotals {
  final double putIn;
  final double value;
  final double dividends;

  const InvestTotals({
    required this.putIn,
    required this.value,
    required this.dividends,
  });

  factory InvestTotals.of(Iterable<InvestProgress> accounts) {
    var putIn = 0.0, value = 0.0, dividends = 0.0;
    for (final a in accounts) {
      putIn += a.putIn;
      value += a.value;
      dividends += a.dividends;
    }
    return InvestTotals(putIn: putIn, value: value, dividends: dividends);
  }

  double get gain => value + dividends - putIn;
  double? get gainPercent => putIn > 0 ? gain / putIn * 100 : null;
}

import 'package:intl/intl.dart';

/// One budget month: from its start day up to (not including) the next
/// cycle's start. With a start day of 1 this is the calendar month; with,
/// say, 25 it runs from the 25th to the 24th of the next month.
class BudgetCycle {
  /// Midnight on the first day, inclusive.
  final DateTime start;

  /// Midnight on the first day of the next cycle, exclusive.
  final DateTime end;

  final int startDay;

  const BudgetCycle._(this.start, this.end, this.startDay);

  /// [day] of the given month, clamped to the days that month actually has
  /// — a start day of 31 lands on the 28th, 29th or 30th in shorter months.
  /// [month] may overflow (0 or 13), which rolls into the adjacent year.
  static DateTime dayOfMonth(int year, int month, int day) {
    final normalized = DateTime(year, month);
    final daysInMonth = DateTime(normalized.year, normalized.month + 1, 0).day;
    return DateTime(
      normalized.year,
      normalized.month,
      day.clamp(1, daysInMonth),
    );
  }

  /// The cycle starting in [year]-[month].
  factory BudgetCycle.startingIn(int year, int month, int startDay) {
    final start = dayOfMonth(year, month, startDay);
    return BudgetCycle._(
      start,
      dayOfMonth(start.year, start.month + 1, startDay),
      startDay,
    );
  }

  /// The cycle that [moment] falls in.
  factory BudgetCycle.containing(DateTime moment, int startDay) {
    final thisMonth = dayOfMonth(moment.year, moment.month, startDay);
    return !moment.isBefore(thisMonth)
        ? BudgetCycle.startingIn(moment.year, moment.month, startDay)
        : BudgetCycle.startingIn(moment.year, moment.month - 1, startDay);
  }

  /// The cycle [offset] cycles away (−1 is the one before).
  BudgetCycle shift(int offset) =>
      BudgetCycle.startingIn(start.year, start.month + offset, startDay);

  BudgetCycle get previous => shift(-1);

  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  /// The last day that belongs to this cycle.
  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);

  // Counted on UTC dates so a daylight-saving shift can't lose or add a day.
  static int _daysBetween(DateTime a, DateTime b) => DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  int get lengthInDays => _daysBetween(start, end);

  /// Every day in the cycle, in order.
  List<DateTime> get days => [
    for (var i = 0; i < lengthInDays; i++)
      DateTime(start.year, start.month, start.day + i),
  ];

  /// Days remaining including today, or 0 once the cycle is over.
  int daysLeft(DateTime now) {
    if (!now.isBefore(end)) return 0;
    if (now.isBefore(start)) return lengthInDays;
    return _daysBetween(now, end);
  }

  /// Days that have happened so far, including today; the whole cycle once
  /// it's over.
  int daysElapsed(DateTime now) {
    if (now.isBefore(start)) return 0;
    if (!now.isBefore(end)) return lengthInDays;
    return _daysBetween(start, now) + 1;
  }

  /// "September 2026", or "Sep 25 – Oct 24, 2026" for a custom start day.
  String get title {
    if (startDay == 1) return DateFormat('MMMM y').format(start);
    final sameYear = start.year == lastDay.year;
    final from = DateFormat(sameYear ? 'MMM d' : 'MMM d, y').format(start);
    return '$from – ${DateFormat('MMM d, y').format(lastDay)}';
  }

  /// "September", or "Sep 25 – Oct 24" — for places that are always about
  /// the current cycle and don't need the year.
  String get shortTitle {
    if (startDay == 1) return DateFormat('MMMM').format(start);
    return '${DateFormat('MMM d').format(start)} – '
        '${DateFormat('MMM d').format(lastDay)}';
  }

  /// "Aug", for comparisons and chart axes.
  String get monthAbbreviation => DateFormat('MMM').format(start);

  /// "Sep 1 – 30" or "Sep 25 – Oct 24".
  String get rangeLabel {
    final from = DateFormat('MMM d').format(start);
    final to = lastDay.month == start.month
        ? DateFormat('d').format(lastDay)
        : DateFormat('MMM d').format(lastDay);
    return '$from – $to';
  }

  @override
  bool operator ==(Object other) =>
      other is BudgetCycle && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'BudgetCycle($start – $end)';
}

/// "1st", "2nd", "3rd", "11th", "22nd"...
String ordinal(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

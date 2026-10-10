import 'package:monthly_traq/models/goal_models.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

enum GoalStatus {
  /// Saved the whole target.
  reached('Reached'),

  /// Saved at least as much as an even pace from the start would have by now.
  onTrack('On track'),

  /// Saved less than that.
  behind('Behind'),

  /// The target date has passed without reaching it.
  overdue('Date passed'),

  /// No target date, so no pace to keep.
  noDate('No date');

  final String label;

  const GoalStatus(this.label);
}

/// Where a goal stands: saved, left, and the pace to reach it in time.
class GoalProgress {
  final GoalModel goal;

  /// Everything saved, including [GoalModel.savedBefore], minus what was
  /// taken out.
  final double saved;

  const GoalProgress._(this.goal, this.saved);

  factory GoalProgress.of(GoalModel goal, Iterable<GoalEntry> entries) {
    var saved = goal.savedBefore;
    for (final e in entries) {
      if (e.goalId != goal.id) continue;
      saved += e.kind == GoalEntryKind.add ? e.amount : -e.amount;
    }
    return GoalProgress._(goal, saved < 0 ? 0 : saved);
  }

  double get remaining {
    final left = goal.target - saved;
    return left > 0.005 ? left : 0;
  }

  bool get isReached => remaining <= 0;

  /// 0–1, for progress bars.
  double get fraction {
    if (goal.target <= 0) return 1;
    final f = saved / goal.target;
    return f > 1 ? 1 : f;
  }

  /// Whole months from [today] to the target date, at least 1 while the
  /// date is still ahead. Null without a date or once it's passed.
  int? monthsLeft(DateTime today) {
    final date = goal.targetDate;
    if (date == null) return null;
    final days = _dateOnly(date).difference(_dateOnly(today)).inDays;
    if (days < 0) return null;
    final months = (days / 30.44).ceil();
    return months < 1 ? 1 : months;
  }

  /// How much to save each month from now to reach the target by its date.
  /// Null without a date, once reached, or once the date has passed.
  double? perMonth(DateTime today) {
    final months = monthsLeft(today);
    if (months == null || isReached) return null;
    return remaining / months;
  }

  GoalStatus status(DateTime today) {
    if (isReached) return GoalStatus.reached;
    final date = goal.targetDate;
    if (date == null) return GoalStatus.noDate;
    final end = _dateOnly(date);
    final now = _dateOnly(today);
    if (now.isAfter(end)) return GoalStatus.overdue;
    final start = _dateOnly(goal.createdAt);
    final span = end.difference(start).inDays;
    if (span <= 0) return GoalStatus.onTrack;
    final elapsed = now.difference(start).inDays.clamp(0, span);
    // An even pace from what was saved at the start to the target.
    final expected =
        goal.savedBefore + (goal.target - goal.savedBefore) * elapsed / span;
    return saved + 0.005 >= expected ? GoalStatus.onTrack : GoalStatus.behind;
  }
}

import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/budget_cycle.dart';

/// Last cycle ended within the budget — Home celebrates it for the first
/// days of the new cycle.
class BudgetWin {
  /// The cycle that just ended.
  final BudgetCycle cycle;
  final double budget;
  final double spent;

  const BudgetWin({
    required this.cycle,
    required this.budget,
    required this.spent,
  });

  /// What was left of the budget when the cycle ended.
  double get leftOver => budget - spent;

  /// Identifies the cycle, to remember that its celebration was dismissed.
  String get id =>
      '${cycle.start.year}-${cycle.start.month}-${cycle.start.day}';

  /// How many days into a new cycle the celebration still shows.
  static const showForDays = 7;

  /// The win for the cycle before [current], or null when there's nothing
  /// to celebrate: no budget, nothing spent last cycle (so it wasn't
  /// tracked), over budget, or the new cycle is more than [showForDays]
  /// old.
  ///
  /// The budget compared against is today's, as budgets aren't kept per
  /// cycle.
  static BudgetWin? forPreviousCycle({
    required double budget,
    required List<TransactionModel> transactions,
    required BudgetCycle current,
    required DateTime now,
  }) {
    if (budget <= 0 || current.daysElapsed(now) > showForDays) return null;
    final previous = current.shift(-1);
    var spent = 0.0;
    var count = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.expense && previous.contains(t.date)) {
        spent += t.amount;
        count++;
      }
    }
    if (count == 0 || spent > budget) return null;
    return BudgetWin(cycle: previous, budget: budget, spent: spent);
  }
}

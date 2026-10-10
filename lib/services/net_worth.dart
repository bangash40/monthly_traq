import 'package:monthly_traq/l10n/app_localizations.dart';
import 'package:monthly_traq/models/goal_models.dart';
import 'package:monthly_traq/models/repayment_models.dart';

/// The pieces Net worth is made of. Each can be switched off.
enum NetWorthPart {
  wallets,
  goals,
  investments,
  balance,
  repayments;

  String label(AppLocalizations l10n) => switch (this) {
    wallets => l10n.wallets,
    goals => l10n.savingsGoals,
    investments => l10n.investments,
    balance => l10n.totalBalance,
    repayments => l10n.stillOwed,
  };

  String detail(AppLocalizations l10n) => switch (this) {
    wallets => l10n.netWorthWalletsAbout,
    goals => l10n.netWorthGoalsAbout,
    investments => l10n.netWorthInvestmentsAbout,
    balance => l10n.netWorthBalanceAbout,
    repayments => l10n.netWorthOwedAbout,
  };

  /// Parts that count against net worth.
  bool get isOwed => this == repayments;
}

/// The goal money Net worth can count without counting it twice: money
/// moved in from monthly money or a wallet (so it's no longer there), less
/// whatever was taken out. "Just recorded" money and what was saved before
/// tracking may still be sitting in a wallet, so it's left out — as are
/// goals marked done, whose money has been spent.
double goalMoneyCounted(List<GoalModel> goals, List<GoalEntry> entries) {
  var total = 0.0;
  for (final g in goals) {
    if (g.isDone) continue;
    var moved = 0.0;
    for (final e in entries) {
      if (e.goalId != g.id) continue;
      if (e.kind == GoalEntryKind.takeOut) {
        moved -= e.amount;
      } else if (e.source != PaymentSource.none) {
        moved += e.amount;
      }
    }
    if (moved > 0) total += moved;
  }
  return total;
}

/// Adds the parts up: everything owned minus what's owed, leaving out the
/// parts in [off].
double netWorthOf(Map<NetWorthPart, double> amounts, Set<NetWorthPart> off) {
  var total = 0.0;
  for (final MapEntry(key: part, value: amount) in amounts.entries) {
    if (off.contains(part)) continue;
    total += part.isOwed ? -amount : amount;
  }
  return total;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// "‹ September 2026 ›" — steps Transactions and Analytics through past
/// budget cycles. The selection lives in the repository, so both tabs stay
/// on the same month. It can't go past the current cycle; tapping the
/// label on a past month jumps back to now.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final c = context.colors;
    final isCurrent = repo.isCurrentCycle;

    return AppCard(
      padding: EdgeInsets.zero,
      radius: AppRadius.button,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous month',
              onPressed: repo.showPreviousCycle,
            ),
            Expanded(
              child: Semantics(
                button: !isCurrent,
                hint: isCurrent ? null : 'Back to this month',
                child: GestureDetector(
                  onTap: isCurrent ? null : repo.showCurrentCycle,
                  child: Text(
                    repo.selectedCycle.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.tabular(
                      AppText.rowTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: isCurrent ? c.faint.withValues(alpha: 0.5) : null,
              ),
              tooltip: 'Next month',
              onPressed: isCurrent ? null : repo.showNextCycle,
            ),
          ],
        ),
      ),
    );
  }
}

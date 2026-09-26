import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

/// "‹ September ›" — steps Transactions and Analytics back through past
/// budget cycles. The selection lives in the repository, so both tabs stay
/// on the same month. Can't step past the current cycle; tapping the label
/// on a past month jumps back to it.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
          onPressed: repo.showPreviousCycle,
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: repo.isCurrentCycle ? null : repo.showCurrentCycle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Text(
                    repo.cycleLabel,
                    style: AppText.sectionTitle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    repo.isCurrentCycle ? 'This month' : 'Tap to return to this month',
                    style: AppText.caption.copyWith(color: onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
          onPressed: repo.isCurrentCycle ? null : repo.showNextCycle,
        ),
      ],
    );
  }
}

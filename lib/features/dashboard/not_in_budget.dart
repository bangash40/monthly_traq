import 'package:flutter/material.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// One line under the budget bar saying what spending was left out of the
/// budget ("not in budget" categories such as loan repayments). It never
/// wraps: one category is named, several are summed up — tap for the
/// breakdown.
class NotInBudgetLine extends StatelessWidget {
  final List<CategoryTotal> totals;

  const NotInBudgetLine({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final sum = totals.fold(0.0, (s, t) => s + t.amount);
    final text = totals.length == 1
        ? 'Not counted: ${totals.single.category.name} · ${money.format(sum)}'
        : 'Not counted: ${money.format(sum)} · ${totals.length} categories';
    final style = AppText.caption.copyWith(fontSize: 13, color: c.muted);

    return Semantics(
      button: true,
      label: '$text. Show details',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _showSheet(context, totals),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: c.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: c.faint),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showSheet(BuildContext context, List<CategoryTotal> totals) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _NotInBudgetSheet(totals: totals),
  );
}

class _NotInBudgetSheet extends StatelessWidget {
  final List<CategoryTotal> totals;

  const _NotInBudgetSheet({required this.totals});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final money = context.money;
    final sum = totals.fold(0.0, (s, t) => s + t.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Not in your budget',
            style: AppText.section.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(
            'This month\'s spending in these categories lowers your balance '
            'and shows in Spent, but doesn\'t use up your monthly budget.',
            style: AppText.body.copyWith(color: c.muted),
          ),
          const SizedBox(height: 18),
          Flexible(
            child: SingleChildScrollView(
              child: GroupCard(
                children: [
                  for (final t in totals)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          IconTile(
                            icon: t.category.icon,
                            color: t.category.color,
                            size: 42,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              t.category.name,
                              style: AppText.rowTitle.copyWith(fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            money.format(t.amount),
                            style: AppText.amount.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (totals.length > 1) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total',
                    style: AppText.rowTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  money.format(sum),
                  style: AppText.amount.copyWith(fontSize: 16),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'To change which categories count, go to Profile → Categories → '
            'Edit.',
            style: AppText.caption.copyWith(fontSize: 13, color: c.muted),
          ),
        ],
      ),
    );
  }
}

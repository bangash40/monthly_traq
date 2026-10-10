import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/analytics/category_detail_screen.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/cycle_stats.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/charts.dart';
import 'package:monthly_traq/widgets/month_switcher.dart';
import 'package:monthly_traq/widgets/motion.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Where the money went (or came from) in the month picked with the month
/// switcher.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  TransactionType _type = TransactionType.expense;

  bool get _isSpending => _type == TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final c = context.colors;
    final money = context.money;
    final breakdown = repo.breakdown(_type);
    final total = repo.selectedTotal(_type);
    final change = percentChange(total, repo.previousTotal(_type));
    final biggest = repo.biggestDay(_type);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: KeptAliveListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Text(context.l10n.tabAnalytics, style: AppText.screenTitle),
          const SizedBox(height: 16),
          const MonthSwitcher(),
          const SizedBox(height: 12),
          AppSegmented<TransactionType>(
            value: _type,
            segments: [
              AppSegment(TransactionType.expense, context.l10n.spending),
              AppSegment(TransactionType.income, context.l10n.income),
            ],
            onChanged: (type) => setState(() => _type = type),
          ),
          const SizedBox(height: 12),
          AppCard(
            radius: AppRadius.largeCard,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: breakdown.isEmpty
                ? EmptyState(
                    card: false,
                    icon: Icons.donut_large,
                    title: _isSpending
                        ? context.l10n.noSpendingIn(
                            repo.selectedCycle.shortTitle,
                          )
                        : context.l10n.noIncomeIn(
                            repo.selectedCycle.shortTitle,
                          ),
                    message: _isSpending
                        ? context.l10n.noSpendingHelp
                        : context.l10n.noIncomeHelp,
                  )
                : Column(
                    children: [
                      CategoryDonut(
                        totals: breakdown,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isSpending
                                  ? context.l10n.spent
                                  : context.l10n.earned,
                              style: AppText.label.copyWith(
                                fontSize: 15,
                                color: c.muted,
                              ),
                            ),
                            FittedBox(
                              child: CountUp(
                                value: total,
                                builder: (context, shown) => Text(
                                  money.format(shown),
                                  style: AppText.amountLarge,
                                ),
                              ),
                            ),
                            if (change != null) ...[
                              const SizedBox(height: 6),
                              _ChangeBadge(
                                change: change,
                                higherIsGood: !_isSpending,
                                versus: repo
                                    .selectedCycle
                                    .previous
                                    .monthAbbreviation,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final (index, row) in breakdown.indexed) ...[
                        if (index > 0) const Divider(height: 1),
                        _BreakdownRow(
                          total: row,
                          share: total <= 0 ? 0 : row.amount / total,
                          barFill: row.amount / breakdown.first.amount,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailScreen(
                                category: row.category,
                                type: _type,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatCard(
                    label: context.l10n.dailyAverage,
                    value: money.format(
                      repo.dailyAverage(_type).roundToDouble(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: context.l10n.biggestDay,
                    value: biggest == null ? '—' : money.format(biggest.amount),
                    detail: biggest == null
                        ? null
                        : DateFormat('EEE, MMM d').format(biggest.day),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            radius: AppRadius.largeCard,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.lastSixMonths,
                        style: AppText.section,
                      ),
                    ),
                    _LegendDot(
                      color: c.incomeFill,
                      label: context.l10n.moneyIn,
                    ),
                    const SizedBox(width: 14),
                    _LegendDot(
                      color: c.spendingFill,
                      label: context.l10n.moneyOut,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                MonthlyTrendChart(months: repo.trend),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "↓ 12% vs Aug" — green when the change is good news, red when it isn't.
class _ChangeBadge extends StatelessWidget {
  final double change;
  final bool higherIsGood;
  final String versus;

  const _ChangeBadge({
    required this.change,
    required this.higherIsGood,
    required this.versus,
  });

  @override
  Widget build(BuildContext context) {
    final percent = change.abs().round();
    if (percent == 0) {
      return TagBadge(context.l10n.sameAs(versus));
    }
    final isUp = change > 0;
    final isGood = isUp == higherIsGood;
    return TagBadge(
      context.l10n.percentVersus(percent, versus),
      icon: isUp ? Icons.arrow_upward : Icons.arrow_downward,
      tone: isGood ? BadgeTone.income : BadgeTone.spending,
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final CategoryTotal total;
  final double share;

  /// Bar length relative to the biggest category, so the top row fills.
  final double barFill;
  final VoidCallback onTap;

  const _BreakdownRow({
    required this.total,
    required this.share,
    required this.barFill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final category = total.category;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            IconTile(icon: category.icon, color: category.color, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          category.displayName(context.l10n),
                          style: AppText.rowTitle.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (category.excludeFromBudget) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: c.surfaceHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            context.l10n.notInBudget,
                            style: AppText.tiny.copyWith(
                              fontSize: 11,
                              color: c.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        context.money.format(total.amount),
                        style: AppText.amount.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: MeterBar(
                          value: barFill,
                          color: category.color,
                          height: 7,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${(share * 100).round()}%',
                          textAlign: TextAlign.right,
                          style: AppText.tabular(
                            AppText.caption.copyWith(
                              fontSize: 13,
                              color: c.muted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: c.faint),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;

  const _StatCard({required this.label, required this.value, this.detail});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label.copyWith(color: c.muted)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.statValue.copyWith(fontSize: 20)),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(detail!, style: AppText.label.copyWith(color: c.muted)),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.label.copyWith(color: context.colors.muted)),
      ],
    );
  }
}

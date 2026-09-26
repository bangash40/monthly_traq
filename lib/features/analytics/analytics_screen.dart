import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/features/analytics/category_transactions_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/category_bar_row.dart';
import 'package:monthly_traq/widgets/category_donut.dart';
import 'package:monthly_traq/widgets/empty_state.dart';
import 'package:monthly_traq/widgets/month_switcher.dart';
import 'package:monthly_traq/widgets/monthly_trend_chart.dart';

/// Where the money went. Category management (add, edit, delete, reorder)
/// lives only in Settings › Category settings, not here.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final breakdown = repo.expenseByCategory;
    final totalExpense = repo.selectedCycleExpense;
    final maxAmount = breakdown.isEmpty ? 0.0 : breakdown.first.value;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final cardColor = Theme.of(context).cardColor;
    final total =
        '${repo.currencySymbol} ${NumberFormat.decimalPattern().format(totalExpense)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const MonthSwitcher(),
          const SizedBox(height: 12),

          Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: breakdown.isEmpty
                ? const EmptyState(
                    icon: Icons.pie_chart_outline,
                    title: 'No spending this month',
                    message: 'Expenses you log will be broken down here.',
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Spending by category',
                            style: AppText.sectionTitle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Tap a category to see its transactions',
                            style: AppText.caption.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: CategoryDonut(
                            entries: breakdown,
                            centerValue: total,
                            centerLabel: 'spent',
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final entry in breakdown)
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CategoryTransactionsScreen(
                                      category: entry.key,
                                    ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: CategoryBarRow(
                                category: entry.key,
                                amount: entry.value,
                                maxAmount: maxAmount,
                                sharePercent: totalExpense <= 0
                                    ? 0
                                    : entry.value / totalExpense * 100,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 28),

          MonthlyTrendChart(months: repo.lastSixMonths),
        ],
      ),
    );
  }
}

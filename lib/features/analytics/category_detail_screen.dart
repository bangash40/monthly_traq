import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/money.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/charts.dart';
import 'package:monthly_traq/widgets/transaction_rows.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// One category in the month Analytics is showing: its total, its share,
/// a by-day chart, and the transactions behind it.
class CategoryDetailScreen extends StatelessWidget {
  final CategoryModel category;
  final TransactionType type;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<TransactionsRepository>();
    final cycle = repo.selectedCycle;
    final transactions = repo.transactionsInCategory(category.id, type);
    final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final overall = repo.selectedTotal(type);
    final share = overall <= 0 ? 0 : (total / overall * 100).round();
    final count = transactions.length;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Row(
            children: [
              const BackCircleButton(),
              Expanded(
                child: Text(
                  cycle.title,
                  textAlign: TextAlign.center,
                  style: AppText.rowTitle.copyWith(
                    fontSize: 16,
                    color: c.muted,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              IconTile(icon: category.icon, color: category.color, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AppText.screenTitle.copyWith(fontSize: 26),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$share% of ${type == TransactionType.expense ? 'spending' : 'income'}'
                      ' · $count ${count == 1 ? 'transaction' : 'transactions'}',
                      style: AppText.body.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              context.money.format(total),
              style: AppText.hero.copyWith(fontSize: 40),
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            radius: AppRadius.largeCard,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'By day',
                        style: AppText.rowTitle.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      cycle.rangeLabel,
                      style: AppText.label.copyWith(color: c.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DailyBars(
                  days: repo.dailyTotals(type, categoryId: category.id),
                  color: category.color,
                ),
              ],
            ),
          ),
          if (transactions.isEmpty) ...[
            const SizedBox(height: 20),
            EmptyState(
              icon: Icons.receipt_long,
              title: 'Nothing in ${cycle.shortTitle}',
              message: 'Transactions in this category show up here.',
            ),
          ] else
            for (final bucket in groupByDay(transactions)) ...[
              DayHeader(bucket),
              GroupCard(
                children: [
                  for (final t in bucket.transactions)
                    TransactionRow(
                      transaction: t,
                      category: category.id.isEmpty ? null : category,
                      subtitle: DateFormat('h:mm a').format(t.date),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditTransactionScreen(existing: t),
                        ),
                      ),
                    ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}

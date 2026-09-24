import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/budget_meter.dart';
import 'package:monthly_traq/widgets/edit_budget_dialog.dart';
import 'package:monthly_traq/widgets/stat_tile.dart';
import 'package:monthly_traq/widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onSeeAllTransactions;

  const DashboardScreen({super.key, this.onSeeAllTransactions});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final currency = NumberFormat.decimalPattern();
    final symbol = repo.currencySymbol;
    final recent = repo.transactions.take(5).toList();
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('MonthlyTraq')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Text(
            'Balance',
            style: TextStyle(fontSize: 14, color: onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            '$symbol ${currency.format(repo.balance)}',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Text(
            'This month · ${repo.cycleLabel}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Income',
                  value: '$symbol ${currency.format(repo.monthlyIncome)}',
                  icon: Icons.arrow_downward_rounded,
                  accentColor: AppPalette.good,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Expense',
                  value: '$symbol ${currency.format(repo.monthlyExpense)}',
                  icon: Icons.arrow_upward_rounded,
                  accentColor: AppPalette.critical,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          BudgetMeter(
            ratio: repo.budgetUsedRatio,
            spentLabel: '$symbol ${currency.format(repo.monthlyExpense)} spent',
            budgetLabel: 'of $symbol ${currency.format(repo.monthlyBudget)}',
            onEdit: () => showEditBudgetDialog(context, repo),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent transactions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: onSeeAllTransactions,
                child: const Text('See all'),
              ),
            ],
          ),

          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No transactions yet.',
                style: TextStyle(color: onSurfaceVariant),
              ),
            )
          else
            ...recent.map(
              (t) => TransactionTile(
                transaction: t,
                category: repo.categoryById(t.categoryId),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTransactionScreen(existing: t),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

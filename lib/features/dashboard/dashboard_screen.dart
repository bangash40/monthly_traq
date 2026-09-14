import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/budget_meter.dart';
import 'package:monthly_traq/widgets/stat_tile.dart';
import 'package:monthly_traq/widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onSeeAllTransactions;

  const DashboardScreen({super.key, this.onSeeAllTransactions});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final currency = NumberFormat.decimalPattern();
    final recent = repo.transactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MonthlyTraq'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          Text(
            'Balance',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${currency.format(repo.balance)}',
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Income',
                  value: 'Rs. ${currency.format(repo.totalIncome)}',
                  icon: Icons.arrow_downward_rounded,
                  accentColor: AppPalette.good,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Expense',
                  value: 'Rs. ${currency.format(repo.totalExpense)}',
                  icon: Icons.arrow_upward_rounded,
                  accentColor: AppPalette.critical,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          BudgetMeter(
            ratio: repo.budgetUsedRatio,
            spentLabel: 'Rs. ${currency.format(repo.totalExpense)} spent',
            budgetLabel: 'of Rs. ${currency.format(repo.monthlyBudget)}',
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
                style: TextStyle(color: Colors.grey.shade600),
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

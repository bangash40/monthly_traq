import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/add_category_dialog.dart';
import 'package:monthly_traq/widgets/category_bar_row.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final breakdown = repo.expenseByCategory;
    final totalExpense = repo.monthlyExpense;
    final maxAmount = breakdown.isEmpty ? 0.0 : breakdown.first.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add category',
            onPressed: () => showAddCategoryDialog(context, repo),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          const Text(
            'Spending by category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            'This month',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          if (breakdown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No expenses recorded this month yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: breakdown
                    .map(
                      (entry) => CategoryBarRow(
                        category: entry.key,
                        amount: entry.value,
                        maxAmount: maxAmount,
                        sharePercent: totalExpense <= 0
                            ? 0
                            : entry.value / totalExpense * 100,
                      ),
                    )
                    .toList(),
              ),
            ),

          const SizedBox(height: 28),
          const Text(
            'Categories',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: repo.categories
                  .map(
                    (c) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: c.color.withValues(alpha: 0.12),
                        child: Icon(c.icon, color: c.color, size: 20),
                      ),
                      title: Text(c.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete category',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await repo.deleteCategory(c.id);
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Could not delete: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

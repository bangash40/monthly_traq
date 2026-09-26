import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/empty_state.dart';
import 'package:monthly_traq/widgets/transaction_tile.dart';

/// The expenses behind one row of the Analytics breakdown — same category,
/// same month as the one Analytics is showing.
class CategoryTransactionsScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryTransactionsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final transactions = repo.expensesInCategory(category.id);
    final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: category.color.withValues(alpha: 0.12),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${repo.currencySymbol} ${NumberFormat.decimalPattern().format(total)}',
                      style: AppText.statValue,
                    ),
                    Text(
                      '${repo.cycleLabel} · ${transactions.length} '
                      '${transactions.length == 1 ? 'transaction' : 'transactions'}',
                      style: AppText.label.copyWith(color: onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long,
              title: 'Nothing here this month',
            )
          else
            for (final (index, t) in transactions.indexed) ...[
              if (index > 0) const Divider(height: 1),
              TransactionTile(
                transaction: t,
                category: category,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTransactionScreen(existing: t),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final transactions = repo.transactions.where((t) {
      if (_categoryFilter == null) return true;
      return t.categoryId == _categoryFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _categoryFilter == null,
                    onSelected: (_) => setState(() => _categoryFilter = null),
                  ),
                ),
                ...repo.categories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(c.icon, size: 16, color: c.color),
                      label: Text(c.name),
                      selected: _categoryFilter == c.id,
                      onSelected: (_) => setState(() => _categoryFilter = c.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Text(
                      'No transactions found.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red.shade400,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context.read<TransactionsRepository>().deleteTransaction(
                            t.id,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaction deleted')),
                          );
                        },
                        child: TransactionTile(
                          transaction: t,
                          category: repo.categoryById(t.categoryId),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditTransactionScreen(existing: t),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

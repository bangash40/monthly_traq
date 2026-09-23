import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/add_category_dialog.dart';

class CategorySettingsScreen extends StatefulWidget {
  const CategorySettingsScreen({super.key});

  @override
  State<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  TransactionType _type = TransactionType.expense;

  Future<void> _addCategory(TransactionsRepository repo) async {
    await showAddCategoryDialog(context, repo, type: _type);
  }

  Future<void> _editCategory(
    TransactionsRepository repo,
    CategoryModel category,
  ) async {
    await showAddCategoryDialog(
      context,
      repo,
      type: category.type,
      existing: category,
    );
  }

  Future<void> _deleteCategory(
    TransactionsRepository repo,
    CategoryModel category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          '"${category.name}" will be removed. Transactions using it will '
          'become uncategorized instead of being deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repo.deleteCategory(category.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  Future<void> _reorder(
    TransactionsRepository repo,
    List<CategoryModel> current,
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = List<CategoryModel>.of(current);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    // Optimistic — the live category list updates immediately from this
    // write's own Firestore snapshot anyway, but reordering feels laggy
    // without this since the drag drop would otherwise snap back first.
    setState(() {});
    try {
      await repo.reorderCategories(reordered);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not reorder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final categories = repo.categories.where((c) => c.type == _type).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Category settings')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TransactionType>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: categories.length,
                onReorderItem: (oldIndex, newIndex) =>
                    _reorder(repo, categories, oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Material(
                    key: ValueKey(category.id),
                    color: Theme.of(context).cardColor,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color,
                        foregroundColor: Colors.white,
                        child: Icon(category.icon, size: 20),
                      ),
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                            onPressed: () => _deleteCategory(repo, category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                            onPressed: () => _editCategory(repo, category),
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.drag_handle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: double.infinity,
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            onPressed: () => _addCategory(repo),
            icon: const Icon(Icons.add),
            label: const Text('Add category'),
          ),
        ),
      ),
    );
  }
}

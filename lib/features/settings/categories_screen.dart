import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/category_editor_sheet.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// Add, rename, delete and reorder categories. The order here is the order
/// on the Add screen.
class CategoriesScreen extends StatefulWidget {
  final TransactionType initialType;

  const CategoriesScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

enum _Action { edit, delete }

class _CategoriesScreenState extends State<CategoriesScreen> {
  late TransactionType _type = widget.initialType;

  Future<void> _delete(CategoryModel category) async {
    final repo = context.read<TransactionsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete ${category.name}?'),
        content: const Text(
          'Transactions in this category are kept and become '
          'uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.colors.spending,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repo.deleteCategory(category.id);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  Future<void> _reorder(List<CategoryModel> current, int from, int to) async {
    final repo = context.read<TransactionsRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final reordered = List<CategoryModel>.of(current);
    reordered.insert(to, reordered.removeAt(from));
    try {
      await repo.reorderCategories(reordered);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not reorder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repo = context.watch<TransactionsRepository>();
    int count(TransactionType type) =>
        repo.categories.where((cat) => cat.type == type).length;
    final categories = repo.categories
        .where((cat) => cat.type == _type)
        .toList();

    return SubPageScaffold(
      title: 'Categories',
      bottom: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => showCategoryEditor(context, type: _type),
          child: const ButtonLabel('New category', icon: Icons.add),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: AppSegmented<TransactionType>(
              value: _type,
              segments: [
                AppSegment(
                  TransactionType.expense,
                  'Expense · ${count(TransactionType.expense)}',
                ),
                AppSegment(
                  TransactionType.income,
                  'Income · ${count(TransactionType.income)}',
                ),
              ],
              onChanged: (type) => setState(() => _type = type),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
            child: Text(
              'Drag to reorder. The order here is the order in the add screen.',
              style: AppText.label.copyWith(fontSize: 14, color: c.muted),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      EmptyState(
                        icon: Icons.category_outlined,
                        title: _type == TransactionType.expense
                            ? 'No expense categories'
                            : 'No income categories',
                        message: 'Add one to start sorting what you log.',
                      ),
                    ],
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    buildDefaultDragHandles: false,
                    itemCount: categories.length,
                    onReorderItem: (from, to) => _reorder(categories, from, to),
                    proxyDecorator: (child, index, animation) => Material(
                      elevation: 8,
                      color: Colors.transparent,
                      shadowColor: Colors.black38,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: child,
                    ),
                    itemBuilder: (context, index) => _CategoryRow(
                      key: ValueKey(categories[index].id),
                      category: categories[index],
                      index: index,
                      isFirst: index == 0,
                      isLast: index == categories.length - 1,
                      onAction: (action) => action == _Action.edit
                          ? showCategoryEditor(
                              context,
                              type: _type,
                              existing: categories[index],
                            )
                          : _delete(categories[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// One row of the list. Rows draw their own slice of the surrounding card
/// (rounded top on the first, rounded bottom on the last) so the list reads
/// as a single card while each row can still be dragged on its own.
class _CategoryRow extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<_Action> onAction;

  const _CategoryRow({
    super.key,
    required this.category,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const r = Radius.circular(AppRadius.card);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? r : Radius.zero,
          bottom: isLast ? r : Radius.zero,
        ),
        border: Border(
          left: BorderSide(color: c.hairline),
          right: BorderSide(color: c.hairline),
          top: isFirst ? BorderSide(color: c.hairline) : BorderSide.none,
          bottom: BorderSide(color: c.hairline),
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Semantics(
              label: 'Drag to reorder ${category.name}',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 10, 20),
                child: Icon(Icons.drag_indicator, color: c.faint),
              ),
            ),
          ),
          IconTile(
            icon: category.icon,
            color: category.color,
            size: 44,
            solid: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppText.rowTitle.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (category.excludeFromBudget)
                  Text(
                    'Not in budget',
                    style: AppText.label.copyWith(color: c.muted),
                  ),
              ],
            ),
          ),
          PopupMenuButton<_Action>(
            tooltip: 'Options for ${category.name}',
            icon: Icon(Icons.more_vert, color: c.ink),
            onSelected: onAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _Action.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: c.muted),
                    const SizedBox(width: 12),
                    const Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _Action.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: c.spending),
                    const SizedBox(width: 12),
                    Text('Delete…', style: TextStyle(color: c.spending)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

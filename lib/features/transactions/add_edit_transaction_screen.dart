import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/add_category_dialog.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;

  const AddEditTransactionScreen({super.key, this.existing});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _amountController = TextEditingController(
    text: widget.existing?.amount.toStringAsFixed(0),
  );
  late final _noteController = TextEditingController(text: widget.existing?.note);

  late TransactionType _type = widget.existing?.type ?? TransactionType.expense;
  late String? _categoryId = widget.existing?.categoryId;
  late DateTime _date = widget.existing?.date ?? DateTime.now();

  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final repo = context.read<TransactionsRepository>();
    final amount = double.parse(_amountController.text);
    final categoryId = _categoryId;

    try {
      if (_isEditing) {
        await repo.updateTransaction(
          widget.existing!.copyWith(
            title: _titleController.text.trim(),
            amount: amount,
            type: _type,
            categoryId: categoryId,
            date: _date,
            note: _noteController.text.trim(),
          ),
        );
      } else {
        await repo.addTransaction(
          TransactionModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: _titleController.text.trim(),
            amount: amount,
            type: _type,
            categoryId: categoryId,
            date: _date,
            note: _noteController.text.trim(),
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    try {
      await context.read<TransactionsRepository>().deleteTransaction(
        widget.existing!.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionsRepository>();
    final categories = repo.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit' : 'Add',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SegmentedButton<TransactionType>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward_rounded),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_downward_rounded),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _type = selection.first;
                        _categoryId = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Groceries',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${repo.currencySymbol} ',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                FormField<String>(
                  key: ValueKey(_type),
                  initialValue: _categoryId,
                  validator: (value) =>
                      value == null ? 'Select a category' : null,
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CategoryGrid(
                          categories: categories
                              .where((c) => c.type == _type)
                              .toList(),
                          selectedId: _categoryId,
                          onSelect: (id) {
                            setState(() => _categoryId = id);
                            field.didChange(id);
                          },
                          onAddCategory: () async {
                            final repo = context.read<TransactionsRepository>();
                            final created = await showAddCategoryDialog(
                              context,
                              repo,
                              type: _type,
                            );
                            if (created != null) {
                              setState(() => _categoryId = created.id);
                              field.didChange(created.id);
                            }
                          },
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(DateFormat('MMM d, yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Add transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddCategory;

  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 18,
      crossAxisSpacing: 4,
      childAspectRatio: 0.72,
      children: [
        for (final category in categories)
          _CategoryTile(
            category: category,
            isSelected: category.id == selectedId,
            onTap: () => onSelect(category.id),
          ),
        _AddCategoryTile(onTap: onAddCategory),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.color.withValues(alpha: 0.18),
              border: isSelected
                  ? Border.all(color: category.color, width: 2.5)
                  : null,
            ),
            child: Icon(category.icon, color: category.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? themeAccent(context)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCategoryTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(Icons.add, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            'Add category',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

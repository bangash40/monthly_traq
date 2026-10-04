import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/category_icons.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// Creates a category, or — given [existing] — renames it and changes its
/// icon. Returns the saved category, or null if cancelled.
Future<CategoryModel?> showCategoryEditor(
  BuildContext context, {
  required TransactionType type,
  CategoryModel? existing,
}) {
  final repo = context.read<TransactionsRepository>();
  if (existing == null && !repo.canAddCategory) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You\'ve reached the category limit')),
    );
    return Future.value(null);
  }
  return showModalBottomSheet<CategoryModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CategoryEditor(type: type, existing: existing),
  );
}

class _CategoryEditor extends StatefulWidget {
  final TransactionType type;
  final CategoryModel? existing;

  const _CategoryEditor({required this.type, this.existing});

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late IconData _icon =
      widget.existing?.icon ?? iconForKey(defaultCategoryIconKey);
  late bool _countsTowardBudget =
      !(widget.existing?.excludeFromBudget ?? false);
  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  bool get _isExpense =>
      (widget.existing?.type ?? widget.type) == TransactionType.expense;

  // New categories get the next color slot for their type — the same one
  // the repository assigns — so the preview matches what gets saved.
  late final Color _color =
      widget.existing?.color ??
      AppPalette.categorical[context
              .read<TransactionsRepository>()
              .categories
              .where((c) => c.type == widget.type)
              .length %
          AppPalette.categorical.length];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give the category a name');
      return;
    }
    setState(() {
      _error = null;
      _isSaving = true;
    });

    final repo = context.read<TransactionsRepository>();
    try {
      final CategoryModel? saved;
      final existing = widget.existing;
      if (existing != null) {
        saved = CategoryModel(
          id: existing.id,
          name: name,
          icon: _icon,
          color: existing.color,
          type: existing.type,
          sortOrder: existing.sortOrder,
          excludeFromBudget: _isExpense && !_countsTowardBudget,
        );
        await repo.updateCategory(saved);
      } else {
        saved = await repo.addCategory(
          name: name,
          icon: _icon,
          type: widget.type,
          excludeFromBudget: _isExpense && !_countsTowardBudget,
        );
      }
      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not ${_isEditing ? 'save' : 'add'} category: $e',
          ),
        ),
      );
    }
  }

  Widget _iconTile(IconData icon) {
    final c = context.colors;
    final selected = icon == _icon;
    return Material(
      color: selected ? _color : c.surfaceHigh,
      borderRadius: BorderRadius.circular(AppRadius.iconTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.iconTile),
        onTap: () => setState(() => _icon = icon),
        child: Icon(icon, size: 22, color: selected ? Colors.white : c.muted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconTile(icon: _icon, color: _color, size: 52, solid: true),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _isEditing ? 'Edit category' : 'New category',
                  style: AppText.section.copyWith(fontSize: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Name and the budget switch up top, the icons scrolling below
          // them, and the button pinned at the bottom — so it's always in
          // reach however many icons there are, keyboard up or not.
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LabeledField(
                    label: 'Name',
                    field: TextField(
                      controller: _nameController,
                      autofocus: !_isEditing,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 40,
                      decoration: InputDecoration(
                        hintText: widget.type == TransactionType.income
                            ? 'e.g. Freelance'
                            : 'e.g. Groceries',
                        errorText: _error,
                        counterText: '',
                      ),
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                  if (_isExpense) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Count toward monthly budget',
                                style: AppText.rowTitle.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _countsTowardBudget
                                    ? 'Spending here uses up your monthly '
                                          'budget.'
                                    : 'Not in budget — for loan repayments, '
                                          'savings and the like. Still lowers '
                                          'your balance.',
                                style: AppText.label.copyWith(color: c.muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: _countsTowardBudget,
                          onChanged: (value) =>
                              setState(() => _countsTowardBudget = value),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Icon',
                    style: AppText.rowTitle.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  for (final group in categoryIconGroups) ...[
                    const SizedBox(height: 14),
                    Text(
                      group.label.toUpperCase(),
                      style: AppText.overline.copyWith(color: c.muted),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        for (final key in group.keys)
                          _iconTile(iconForKey(key)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: ButtonLabel(
              _isEditing ? 'Save changes' : 'Add category',
              loading: _isSaving,
            ),
          ),
        ],
      ),
    );
  }
}

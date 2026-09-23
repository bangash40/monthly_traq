import 'package:flutter/material.dart';
import 'package:monthly_traq/models/category_model.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

const _kCategoryIconChoices = [
  Icons.category,
  Icons.fastfood,
  Icons.local_hospital,
  Icons.flight,
  Icons.home,
  Icons.pets,
  Icons.fitness_center,
  Icons.card_giftcard,
];

/// Shows a dialog to create a new category, or — when [existing] is passed —
/// to rename/re-icon that one instead. Returns the created/updated category,
/// or null if the user cancelled (or, for a new category, the cap was
/// already reached).
Future<CategoryModel?> showAddCategoryDialog(
  BuildContext context,
  TransactionsRepository repo, {
  required TransactionType type,
  CategoryModel? existing,
}) async {
  if (existing == null && !repo.canAddCategory) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Category limit reached')));
    return null;
  }

  final isEditing = existing != null;
  final nameController = TextEditingController(text: existing?.name);
  IconData selectedIcon = existing?.icon ?? _kCategoryIconChoices.first;
  bool isSaving = false;

  return showDialog<CategoryModel>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit category' : 'Add category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kCategoryIconChoices.map((icon) {
                      final isSelected = icon == selectedIcon;
                      return InkWell(
                        onTap: () => setState(() => selectedIcon = icon),
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(dialogContext).colorScheme.primary
                              : Theme.of(dialogContext)
                                    .colorScheme
                                    .surfaceContainerHighest,
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(dialogContext)
                                      .colorScheme
                                      .onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        setState(() => isSaving = true);
                        try {
                          final CategoryModel? result;
                          if (isEditing) {
                            final updated = CategoryModel(
                              id: existing.id,
                              name: name,
                              icon: selectedIcon,
                              color: existing.color,
                              type: existing.type,
                              sortOrder: existing.sortOrder,
                            );
                            await repo.updateCategory(updated);
                            result = updated;
                          } else {
                            result = await repo.addCategory(
                              name: name,
                              icon: selectedIcon,
                              type: type,
                            );
                          }
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, result);
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not ${isEditing ? 'update' : 'add'} category: $e',
                                ),
                              ),
                            );
                            setState(() => isSaving = false);
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Save' : 'Add'),
              ),
            ],
          );
        },
      );
    },
  );
}

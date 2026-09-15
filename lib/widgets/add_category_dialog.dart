import 'package:flutter/material.dart';
import 'package:monthly_traq/models/category_model.dart';
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

/// Shows a dialog to create a new spending category with any name the user
/// wants, picking a slot color automatically. Returns the created category,
/// or null if the user cancelled or the category cap was already reached.
Future<CategoryModel?> showAddCategoryDialog(
  BuildContext context,
  TransactionsRepository repo,
) async {
  if (!repo.canAddCategory) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Category limit reached')));
    return null;
  }

  final nameController = TextEditingController();
  IconData selectedIcon = _kCategoryIconChoices.first;

  return showDialog<CategoryModel>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Add category'),
            content: Column(
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
                            : Colors.grey.shade200,
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final created = await repo.addCategory(
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, created);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}

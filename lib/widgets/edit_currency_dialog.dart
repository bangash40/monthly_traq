import 'package:flutter/material.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

const _presetSymbols = ['Rs.', '\$', '€', '£', '₹', '¥'];

/// Shows a dialog to pick (or type) the currency symbol shown throughout
/// the app. This only changes the label — there's no conversion between
/// currencies.
Future<void> showEditCurrencyDialog(
  BuildContext context,
  TransactionsRepository repo,
) {
  final controller = TextEditingController(text: repo.currencySymbol);
  bool isSaving = false;

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Currency symbol'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _presetSymbols.map((symbol) {
                      final isSelected = controller.text == symbol;
                      return ChoiceChip(
                        label: Text(symbol),
                        selected: isSelected,
                        onSelected: (_) => setState(() => controller.text = symbol),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLength: 10,
                    decoration: const InputDecoration(
                      labelText: 'Custom symbol',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
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
                        final symbol = controller.text.trim();
                        if (symbol.isEmpty) return;
                        setState(() => isSaving = true);
                        try {
                          await repo.updateCurrencySymbol(symbol);
                          if (dialogContext.mounted) Navigator.pop(dialogContext);
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Could not save: $e')),
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
                    : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

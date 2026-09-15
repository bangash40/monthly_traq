import 'package:flutter/material.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

/// Shows a dialog to edit the user's monthly budget. Writes straight to
/// Firestore via the repository; the dashboard updates through the live
/// snapshot listener once the write lands.
Future<void> showEditBudgetDialog(
  BuildContext context,
  TransactionsRepository repo,
) {
  final controller = TextEditingController(
    text: repo.monthlyBudget.toStringAsFixed(0),
  );
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Edit monthly budget'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Budget',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return 'Enter a valid amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await repo.updateMonthlyBudget(double.parse(controller.text));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

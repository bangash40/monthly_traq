import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

/// Deletes [transaction], then shows a snackbar whose Undo puts it back
/// under its original id. Returns false (after telling the user) if the
/// delete itself failed.
Future<bool> deleteTransactionWithUndo(
  BuildContext context,
  TransactionModel transaction,
) async {
  final repo = context.read<TransactionsRepository>();
  final messenger = ScaffoldMessenger.of(context);

  try {
    await repo.deleteTransaction(transaction.id);
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Couldn\'t delete the transaction. Please try again.'),
      ),
    );
    return false;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: const Text('Transaction deleted'),
      // A snackbar with an action stays up until it's tapped unless told
      // otherwise; Undo should fade away on its own like in other apps.
      persist: false,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          try {
            await repo.restoreTransaction(transaction);
          } catch (_) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Couldn\'t bring the transaction back. Please try again.',
                ),
              ),
            );
          }
        },
      ),
    ),
  );
  return true;
}

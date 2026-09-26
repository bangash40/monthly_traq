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
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    return false;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: const Text('Transaction deleted'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          try {
            await repo.restoreTransaction(transaction);
          } catch (e) {
            messenger.showSnackBar(
              SnackBar(content: Text('Could not restore: $e')),
            );
          }
        },
      ),
    ),
  );
  return true;
}

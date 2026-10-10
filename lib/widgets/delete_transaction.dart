import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';
import 'package:monthly_traq/app/haptics.dart';
import 'package:monthly_traq/models/transaction_model.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Deletes [transaction], then shows a snackbar whose Undo puts it back
/// under its original id. Returns false (after telling the user) if the
/// delete itself failed.
Future<bool> deleteTransactionWithUndo(
  BuildContext context,
  TransactionModel transaction,
) async {
  final repo = context.read<TransactionsRepository>();
  final messenger = ScaffoldMessenger.of(context);
  final hapticsOn = context.read<AppSettings>().hapticFeedback;
  final l10n = context.l10n;

  try {
    await repo.deleteTransaction(transaction.id);
  } catch (_) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.transactionDeleteFailed)),
    );
    return false;
  }

  if (hapticsOn) playHaptic(Haptic.delete);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.transactionDeleted),
      // A snackbar with an action stays up until it's tapped unless told
      // otherwise; Undo should fade away on its own like in other apps.
      persist: false,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () async {
          if (hapticsOn) playHaptic(Haptic.tap);
          try {
            await repo.restoreTransaction(transaction);
          } catch (_) {
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.transactionRestoreFailed)),
            );
          }
        },
      ),
    ),
  );
  return true;
}

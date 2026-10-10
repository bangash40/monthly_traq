import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/auth_errors.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/l10n/l10n.dart';

/// Permanently deletes the signed-in account and everything in it.
///
/// Firebase only allows deleting an account right after signing in, so this
/// confirms, re-checks the user's password (or Google account), deletes
/// their data, and only then deletes the sign-in. If deleting the data
/// fails, the account is left untouched rather than half-deleted.
Future<void> deleteAccountFlow(BuildContext context) async {
  final repo = context.read<TransactionsRepository>();
  final auth = AuthService();
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  final l10n = context.l10n;
  void toast(String message) =>
      messenger.showSnackBar(SnackBar(content: Text(message)));

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.deleteAccountTitle),
      content: Text(l10n.deleteAccountBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(
            foregroundColor: dialogContext.colors.spending,
          ),
          child: Text(l10n.deleteAccount),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    if (auth.usesPassword) {
      final password = await _askForPassword(context);
      if (password == null) return;
      await auth.reauthenticateWithPassword(password);
    } else if (!await auth.reauthenticateWithGoogle()) {
      return; // cancelled the account picker
    }
  } catch (e) {
    toast(authErrorMessage(l10n, e, AuthAction.confirmIdentity));
    return;
  }

  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(l10n.deletingAccount)),
          ],
        ),
      ),
    ),
  );

  try {
    await repo.deleteAllUserData();
    await auth.deleteCurrentUser();
    navigator.pop();
    toast(l10n.accountDeleted);
  } catch (e) {
    navigator.pop();
    toast(authErrorMessage(l10n, e, AuthAction.deleteAccount));
  }
}

Future<String?> _askForPassword(BuildContext context) async {
  final password = await showDialog<String>(
    context: context,
    builder: (_) => const _PasswordDialog(),
  );
  return (password == null || password.isEmpty) ? null : password;
}

/// Owns its text controller so it's disposed only after the dialog's
/// closing animation — disposing it as soon as showDialog returns crashes
/// the TextField that is still animating out.
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.confirmItsYou),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.confirmPasswordToDelete),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(hintText: context.l10n.password),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(context.l10n.continueButton),
        ),
      ],
    );
  }
}

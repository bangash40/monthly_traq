import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/auth_errors.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

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
  void toast(String message) =>
      messenger.showSnackBar(SnackBar(content: Text(message)));

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete your account?'),
      content: const Text(
        'This permanently deletes your account and everything in it: your '
        'transactions, categories, budget and profile photo. This can\'t be '
        'undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(
            foregroundColor: dialogContext.colors.spending,
          ),
          child: const Text('Delete account'),
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
    toast(authErrorMessage(e, AuthAction.confirmIdentity));
    return;
  }

  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Deleting your account…')),
          ],
        ),
      ),
    ),
  );

  try {
    await repo.deleteAllUserData();
    await auth.deleteCurrentUser();
    navigator.pop();
    toast('Your account has been deleted.');
  } catch (e) {
    navigator.pop();
    toast(authErrorMessage(e, AuthAction.deleteAccount));
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
      title: const Text('Confirm it\'s you'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter your password to delete your account.'),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(hintText: 'Password'),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Continue')),
      ],
    );
  }
}

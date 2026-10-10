import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monthly_traq/app/app_info.dart';
import 'package:monthly_traq/l10n/app_localizations.dart';

/// What the user was trying to do when an error happened — the same error
/// code can need different wording (a wrong password at login vs. when
/// confirming it's you).
enum AuthAction {
  logIn,
  signUp,
  google,
  resetPassword,
  confirmIdentity,
  deleteAccount;

  /// "Couldn't log you in." and the like.
  String failed(AppLocalizations l10n) => switch (this) {
    logIn => l10n.authFailedLogIn,
    signUp => l10n.authFailedSignUp,
    google => l10n.authFailedGoogle,
    resetPassword => l10n.authFailedReset,
    confirmIdentity => l10n.authFailedConfirm,
    deleteAccount => l10n.authFailedDelete,
  };
}

/// Turns any error from signing in, signing up and similar account actions
/// into a short message a user can act on — never raw Firebase text.
String authErrorMessage(
  AppLocalizations l10n,
  Object error,
  AuthAction action,
) {
  final fallback = l10n.authTryAgain(action.failed(l10n));

  if (error is GoogleSignInException) {
    return switch (error.code) {
      GoogleSignInExceptionCode.interrupted => l10n.authGoogleInterrupted,
      GoogleSignInExceptionCode.userMismatch => l10n.authGoogleWrongAccount,
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError ||
      GoogleSignInExceptionCode.uiUnavailable => l10n.authGoogleUnavailable,
      _ => _withCode(fallback, error.code.name),
    };
  }

  if (error is! FirebaseException) return fallback;

  return switch (error.code) {
    'network-request-failed' || 'unavailable' => l10n.authNoInternet,
    'too-many-requests' => l10n.authTooManyAttempts,
    'invalid-email' => l10n.authInvalidEmail,
    'missing-email' => l10n.authMissingEmail,
    'missing-password' => l10n.authMissingPassword,
    'user-disabled' => l10n.authUserDisabled(AppInfo.supportEmail),
    'email-already-in-use' => l10n.authEmailInUse,
    'weak-password' ||
    'password-does-not-meet-requirements' => l10n.authWeakPassword,
    'account-exists-with-different-credential' => l10n.authExistsWithPassword,
    'user-mismatch' when action == AuthAction.confirmIdentity =>
      l10n.authGoogleWrongAccount,
    'user-mismatch' => l10n.authUserMismatch,
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'INVALID_LOGIN_CREDENTIALS' => switch (action) {
      AuthAction.logIn => l10n.authWrongLogin,
      AuthAction.confirmIdentity ||
      AuthAction.deleteAccount => l10n.authWrongPassword,
      _ => fallback,
    },
    'requires-recent-login' || 'user-token-expired' => l10n.authLogInAgain,
    'operation-not-allowed' => l10n.authMethodUnavailable,
    'quota-exceeded' => l10n.authBusy,
    _ => _withCode(fallback, error.code),
  };
}

/// Debug builds add the error code, which makes a failure easy to look up;
/// release builds keep the message clean.
String _withCode(String message, String code) =>
    kDebugMode ? '$message ($code)' : message;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:monthly_traq/app/app_info.dart';

/// What the user was trying to do when an error happened — the same error
/// code can need different wording (a wrong password at login vs. when
/// confirming it's you).
enum AuthAction {
  logIn("Couldn't log you in."),
  signUp("Couldn't create your account."),
  google("Couldn't sign in with Google."),
  resetPassword("Couldn't send the reset email."),
  confirmIdentity("Couldn't confirm it's you."),
  deleteAccount("Couldn't delete your account.");

  final String failed;

  const AuthAction(this.failed);
}

/// Turns any error from signing in, signing up and similar account actions
/// into a short message a user can act on — never raw Firebase text.
String authErrorMessage(Object error, AuthAction action) {
  final fallback = '${action.failed} Please try again.';

  if (error is GoogleSignInException) {
    return switch (error.code) {
      GoogleSignInExceptionCode.interrupted =>
        'Google sign-in was interrupted. Please try again.',
      GoogleSignInExceptionCode.userMismatch =>
        'Choose the Google account you signed up with.',
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError ||
      GoogleSignInExceptionCode.uiUnavailable =>
        'Google sign-in isn\'t available right now. Use your email instead.',
      _ => _withCode(fallback, error.code.name),
    };
  }

  if (error is! FirebaseException) return fallback;

  return switch (error.code) {
    'network-request-failed' || 'unavailable' =>
      'No internet connection. Check your connection and try again.',
    'too-many-requests' =>
      'Too many attempts. Wait a few minutes, then try again.',
    'invalid-email' => 'That email address doesn\'t look right.',
    'missing-email' => 'Enter your email address.',
    'missing-password' => 'Enter your password.',
    'user-disabled' =>
      'This account has been turned off. Contact ${AppInfo.supportEmail} '
          'for help.',
    'email-already-in-use' =>
      'That email already has an account. Log in instead.',
    'weak-password' ||
    'password-does-not-meet-requirements' => 'Choose a stronger password.',
    'account-exists-with-different-credential' =>
      'That email already has an account. Log in with your email and '
          'password.',
    'user-mismatch' when action == AuthAction.confirmIdentity =>
      'Choose the Google account you signed up with.',
    'user-mismatch' =>
      'That doesn\'t match the account you\'re signed in with.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'INVALID_LOGIN_CREDENTIALS' => switch (action) {
      AuthAction.logIn => 'That email and password don\'t match an account.',
      AuthAction.confirmIdentity ||
      AuthAction.deleteAccount => 'That password isn\'t right.',
      _ => fallback,
    },
    'requires-recent-login' || 'user-token-expired' =>
      'For your security, log out and back in, then try again.',
    'operation-not-allowed' =>
      'This way of signing in isn\'t available right now.',
    'quota-exceeded' => 'We\'re busy right now. Please try again later.',
    _ => _withCode(fallback, error.code),
  };
}

/// Debug builds add the error code, which makes a failure easy to look up;
/// release builds keep the message clean.
String _withCode(String message, String code) =>
    kDebugMode ? '$message ($code)' : message;

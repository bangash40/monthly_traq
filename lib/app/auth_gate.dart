import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monthly_traq/app/main_shell.dart';
import 'package:monthly_traq/features/auth/login_screen.dart';

class AuthGate extends StatefulWidget {
  /// True right after a fresh install finishes onboarding — a new user has
  /// no account yet, so they should land on sign-up rather than login.
  final bool startOnSignup;

  const AuthGate({super.key, this.startOnSignup = false});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Only the very first time this AuthGate resolves to "not signed in"
  // should honor startOnSignup — if the user later signs out mid-session,
  // that's a returning user and belongs on login, not sign-up again.
  late bool _startOnSignup = widget.startOnSignup;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainShell();
        }

        final startOnSignup = _startOnSignup;
        _startOnSignup = false;
        return LoginScreen(startOnSignup: startOnSignup);
      },
    );
  }
}

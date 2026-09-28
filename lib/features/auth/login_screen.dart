import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/auth/signup_screen.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/google_sign_in_button.dart';
import 'package:monthly_traq/widgets/ui.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
  return null;
}

class LoginScreen extends StatefulWidget {
  /// True right after a fresh install finishes onboarding — a new user has
  /// no account yet, so this pushes straight to sign-up on first frame
  /// instead of sitting on the login form.
  final bool startOnSignup;

  const LoginScreen({super.key, this.startOnSignup = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    if (widget.startOnSignup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openSignup();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthGate swaps to the app when the auth state changes.
    } on FirebaseAuthException catch (e) {
      _toast(switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'That email and password don\'t match an account.',
        'too-many-requests' => 'Too many attempts. Try again in a few minutes.',
        'network-request-failed' => 'No internet connection.',
        _ => e.message ?? 'Log in failed',
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (validateEmail(email) != null) {
      _toast('Enter your email above, then tap Forgot? again.');
      return;
    }
    try {
      await _authService.sendPasswordReset(email);
      _toast('If $email has an account, a reset link is on its way.');
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? 'Could not send the reset email');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) return; // cancelled the account picker
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        if (!mounted) return;
        await context.read<TransactionsRepository>().seedDefaultsForNewUser();
      }
    } catch (e) {
      _toast('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogoTile(),
                ),
                const SizedBox(height: 32),
                const Text('Welcome back', style: AppText.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Log in to keep tracking your month.',
                  style: AppText.body.copyWith(fontSize: 17, color: c.muted),
                ),
                const SizedBox(height: 32),
                LabeledField(
                  label: 'Email',
                  field: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: validateEmail,
                  ),
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Password',
                  trailing: TextButton(
                    onPressed: _forgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Forgot?'),
                  ),
                  field: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      hintText: 'Your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your password'
                        : null,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: ButtonLabel('Log in', loading: _isLoading),
                ),
                const SizedBox(height: 24),
                const OrDivider(),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  loading: _isGoogleLoading,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 28),
                AuthFooterLink(
                  prompt: 'New to MonthlyTraq?',
                  action: 'Create account',
                  onTap: _openSignup,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "New to MonthlyTraq? Create account" below the buttons on the auth
/// screens. It scrolls with the form rather than being pinned to the bottom,
/// so it stays next to the buttons and doesn't ride up on the keyboard.
class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prompt,
          style: AppText.body.copyWith(fontSize: 16, color: c.muted),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text(action, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

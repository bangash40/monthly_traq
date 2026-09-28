import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/auth/login_screen.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/google_sign_in_button.dart';
import 'package:monthly_traq/widgets/ui.dart';

const _minPasswordLength = 6;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  bool get _passwordLongEnough =>
      _passwordController.text.length >= _minPasswordLength;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await context.read<TransactionsRepository>().seedDefaultsForNewUser();
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _toast(switch (e.code) {
        'email-already-in-use' =>
          'That email already has an account. Log in instead.',
        'weak-password' => 'Choose a longer password.',
        'network-request-failed' => 'No internet connection.',
        _ => e.message ?? 'Sign up failed',
      });
    } catch (e) {
      _toast('Sign up failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _toast('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ok = _passwordLongEnough;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackCircleButton(),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Create your account',
                      style: AppText.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'It takes less than a minute.',
                      style: AppText.body.copyWith(
                        fontSize: 17,
                        color: c.muted,
                      ),
                    ),
                    const SizedBox(height: 30),
                    LabeledField(
                      label: 'Full name',
                      field: TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Your name',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Enter your name'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'Email',
                      field: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                        ),
                        validator: validateEmail,
                      ),
                    ),
                    const SizedBox(height: 18),
                    LabeledField(
                      label: 'Password',
                      field: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: (_) => _signUp(),
                        decoration: InputDecoration(
                          hintText: 'Create a password',
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
                        validator: (value) =>
                            (value ?? '').length < _minPasswordLength
                            ? 'Use at least $_minPasswordLength characters'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          ok
                              ? Icons.check_circle_outline
                              : Icons.circle_outlined,
                          size: 20,
                          color: ok ? c.income : c.faint,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'At least $_minPasswordLength characters',
                          style: AppText.rowTitle.copyWith(
                            fontSize: 14,
                            color: ok ? c.income : c.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: ButtonLabel('Create account', loading: _isLoading),
                    ),
                    const SizedBox(height: 14),
                    GoogleSignInButton(
                      label: 'Sign up with Google',
                      loading: _isGoogleLoading,
                      onPressed: _signInWithGoogle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AuthFooterLink(
                prompt: 'Already have an account?',
                action: 'Log in',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

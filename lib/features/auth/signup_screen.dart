import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/auth/auth_validation.dart';
import 'package:monthly_traq/features/auth/email_field.dart';
import 'package:monthly_traq/features/auth/login_screen.dart';
import 'package:monthly_traq/services/auth_errors.dart';
import 'package:monthly_traq/services/auth_service.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/google_sign_in_button.dart';
import 'package:monthly_traq/widgets/ui.dart';
import 'package:monthly_traq/l10n/l10n.dart';

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
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
    final l10n = context.l10n;
    try {
      await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await context.read<TransactionsRepository>().seedDefaultsForNewUser();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _toast(authErrorMessage(l10n, e, AuthAction.signUp));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    final l10n = context.l10n;
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential == null) return; // cancelled the account picker
      if (credential.additionalUserInfo?.isNewUser ?? false) {
        if (!mounted) return;
        await context.read<TransactionsRepository>().seedDefaultsForNewUser();
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _toast(authErrorMessage(l10n, e, AuthAction.google));
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Widget _visibilityToggle() => IconButton(
    tooltip: _obscurePassword
        ? context.l10n.showPassword
        : context.l10n.hidePassword,
    icon: Icon(
      _obscurePassword
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
    ),
    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SafeArea(
        top: false,
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
                Text(context.l10n.createYourAccount, style: AppText.titleLarge),
                const SizedBox(height: 8),
                Text(
                  context.l10n.signupSubtitle,
                  style: AppText.body.copyWith(fontSize: 17, color: c.muted),
                ),
                const SizedBox(height: 30),
                LabeledField(
                  label: context.l10n.fullName,
                  field: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: context.l10n.yourName,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? context.l10n.nameRequired
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: context.l10n.email,
                  field: EmailField(
                    controller: _emailController,
                    validator: (value) =>
                        validateSignupEmail(context.l10n, value),
                  ),
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: context.l10n.password,
                  field: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    // Rebuild so the strength bar below updates as they type.
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: context.l10n.passwordRequired,
                      suffixIcon: _visibilityToggle(),
                    ),
                    validator: (value) => validateNewPassword(
                      context.l10n,
                      value,
                      name: _nameController.text,
                      email: _emailController.text,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _PasswordStrengthMeter(
                  check: checkNewPassword(
                    context.l10n,
                    _passwordController.text,
                    name: _nameController.text,
                    email: _emailController.text,
                  ),
                  // Once the form has been submitted the field shows the
                  // problem itself, so don't repeat it here.
                  showProblem: _autovalidate == AutovalidateMode.disabled,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: context.l10n.confirmPassword,
                  field: TextFormField(
                    controller: _confirmController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _signUp(),
                    decoration: InputDecoration(
                      hintText: context.l10n.passwordAgain,
                      suffixIcon: _visibilityToggle(),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return context.l10n.passwordAgain;
                      }
                      if (value != _passwordController.text) {
                        return context.l10n.passwordsDontMatch;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: ButtonLabel(
                    context.l10n.createAccount,
                    loading: _isLoading,
                  ),
                ),
                const SizedBox(height: 14),
                GoogleSignInButton(
                  label: context.l10n.signUpWithGoogle,
                  loading: _isGoogleLoading,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 28),
                AuthFooterLink(
                  prompt: context.l10n.alreadyHaveAccount,
                  action: context.l10n.logIn,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A three-step bar (Weak / Okay / Strong) under the password field, with a
/// one-line hint about what to do next.
class _PasswordStrengthMeter extends StatelessWidget {
  final PasswordCheck check;
  final bool showProblem;

  const _PasswordStrengthMeter({
    required this.check,
    required this.showProblem,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (filled, color, label, hint) = switch (check.strength) {
      PasswordStrength.empty => (
        0,
        c.faint,
        null,
        context.l10n.passwordStrengthEmpty(minPasswordLength),
      ),
      PasswordStrength.weak => (
        1,
        c.spending,
        context.l10n.passwordWeak,
        showProblem ? check.problem : null,
      ),
      PasswordStrength.okay => (
        2,
        c.warning,
        context.l10n.passwordOkay,
        context.l10n.passwordOkayHint,
      ),
      PasswordStrength.strong => (
        3,
        c.income,
        context.l10n.passwordStrong,
        context.l10n.passwordStrongHint,
      ),
    };

    return Semantics(
      label: label == null
          ? hint
          : context.l10n.passwordStrengthLabel(label, hint ?? ''),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 6,
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < filled ? color : c.surfaceHigh,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              SizedBox(
                width: 64,
                child: Text(
                  label ?? '',
                  textAlign: TextAlign.end,
                  style: AppText.rowTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          if (hint != null)
            Text(
              hint,
              style: AppText.body.copyWith(fontSize: 14, color: c.muted),
            ),
        ],
      ),
    );
  }
}

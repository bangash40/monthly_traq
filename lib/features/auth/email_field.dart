import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/auth/auth_validation.dart';

/// The email field on the login and sign-up screens. If the address looks
/// like a misspelled provider ("ali@gmial.com"), it offers a one-tap fix
/// underneath once the user pauses or leaves the field — not on every
/// keystroke, so it doesn't flicker while they're still typing.
class EmailField extends StatefulWidget {
  final TextEditingController controller;
  final bool showIcon;

  /// Sign-up passes [validateSignupEmail], which also turns away placeholder
  /// and temporary addresses; login keeps the plain format check.
  final FormFieldValidator<String> validator;

  const EmailField({
    super.key,
    required this.controller,
    this.showIcon = false,
    this.validator = validateEmail,
  });

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  static const _pause = Duration(milliseconds: 800);

  final _focusNode = FocusNode();
  Timer? _debounce;
  String? _suggestion;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _checkForTypo();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    if (_suggestion != null) setState(() => _suggestion = null);
    _debounce?.cancel();
    _debounce = Timer(_pause, _checkForTypo);
  }

  void _checkForTypo() {
    _debounce?.cancel();
    if (!mounted) return;
    var suggestion = emailTypoSuggestion(widget.controller.text);
    // Never suggest an address the form would refuse anyway, like
    // "test.om" → "test.com" on sign-up.
    if (suggestion != null && widget.validator(suggestion) != null) {
      suggestion = null;
    }
    if (suggestion != _suggestion) setState(() => _suggestion = suggestion);
  }

  void _applySuggestion() {
    final suggestion = _suggestion;
    if (suggestion == null) return;
    widget.controller.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    setState(() => _suggestion = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final suggestion = _suggestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'you@example.com',
            prefixIcon: widget.showIcon ? const Icon(Icons.mail_outline) : null,
          ),
          validator: widget.validator,
        ),
        if (suggestion != null)
          Semantics(
            button: true,
            label: 'Did you mean $suggestion? Tap to use it.',
            excludeSemantics: true,
            child: InkWell(
              onTap: _applySuggestion,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Did you mean '),
                      TextSpan(
                        text: suggestion,
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                  style: AppText.body.copyWith(fontSize: 15, color: c.muted),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

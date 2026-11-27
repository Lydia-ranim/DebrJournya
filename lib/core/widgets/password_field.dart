import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import 'app_text_field.dart';

/// Password box with a show/hide eye at the end. Stays left to right in
/// Arabic, like e-mail addresses.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.error,
    this.helper,
    this.isNew = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? error;
  final String? helper;

  /// A password being created (autofill offers to generate one).
  final bool isNew;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  static const _eyeSize = 20.0;
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      error: widget.error,
      helper: widget.helper,
      obscureText: _hidden,
      forceLtr: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: [
        widget.isNew ? AutofillHints.newPassword : AutofillHints.password,
      ],
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: IconButton(
        tooltip: _hidden ? l.authShowPassword : l.authHidePassword,
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? LucideIcons.eye : LucideIcons.eyeOff,
          size: _eyeSize,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

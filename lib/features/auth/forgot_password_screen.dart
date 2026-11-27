import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/notice_box.dart';
import 'data/auth_repository.dart';
import 'domain/credentials.dart';
import 'widgets/auth_layout.dart';

/// Mot de passe oublié: e-mails a recovery code, then [onCodeSent] opens
/// the code screen (which leads to the new-password screen).
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
    this.onBack,
    this.onCodeSent,
  });

  final String initialEmail;
  final VoidCallback? onBack;
  final ValueChanged<String>? onCodeSent;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with OfflineBanner {
  late final _email = TextEditingController(text: widget.initialEmail);
  String? _emailError;
  String? _notice;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _fail(VoidCallback update) {
    if (mounted) setState(update);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final email = Credentials.normalizeEmail(_email.text);
    setState(() {
      _emailError = null;
      _notice = null;
    });
    if (!Credentials.isEmail(email)) {
      setState(() => _emailError = l.authInvalidEmail);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendCode(email, CodePurpose.recovery);
      if (mounted) widget.onCodeSent?.call(email);
    } on NoConnectionException {
      _fail(showOffline);
    } on TooManyRequestsException {
      _fail(() => _notice = l.commonTooManyRequests);
    } on Exception catch (e) {
      debugPrint('password reset failed: $e');
      _fail(() => _notice = l.commonUnexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthLayout(
      title: l.forgotTitle,
      lead: AuthLead(l.forgotLead),
      onBack: widget.onBack,
      offline: offline,
      children: [
        AppTextField(
          label: l.authEmailLabel,
          controller: _email,
          hint: l.authEmailHint,
          forceLtr: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          error: _emailError,
          onChanged: (_) => setState(() => _emailError = null),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AuthGaps.beforeButton),
        if (_notice != null) ...[
          NoticeBox(message: _notice!),
          const SizedBox(height: AuthGaps.between),
        ],
        AppButton(label: l.forgotButton, loading: _busy, onPressed: _submit),
      ],
    );
  }
}

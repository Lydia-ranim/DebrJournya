import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_checkbox.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/linked_text.dart';
import '../../core/widgets/notice_box.dart';
import '../../core/widgets/password_field.dart';
import 'data/auth_repository.dart';
import 'domain/credentials.dart';
import 'widgets/auth_layout.dart';
import 'widgets/social_buttons.dart';

/// Inscription: e-mail + password + consent → a 6-digit code is e-mailed
/// and [onCodeSent] opens the code screen. Google / Facebook create the
/// account directly (consent required too).
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({
    super.key,
    this.onBack,
    this.onSignIn,
    this.onCodeSent,
    this.onOpenTerms,
    this.onOpenPrivacy,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSignIn;
  final ValueChanged<String>? onCodeSent;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with OfflineBanner {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _accepted = false;
  String? _emailError;
  String? _passwordError;
  String? _notice;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearErrors() => setState(() {
    _emailError = null;
    _passwordError = null;
    _notice = null;
  });

  void _fail(VoidCallback update) {
    if (mounted) setState(update);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final email = Credentials.normalizeEmail(_email.text);
    _clearErrors();
    var ok = true;
    if (!Credentials.isEmail(email)) {
      _emailError = l.authInvalidEmail;
      ok = false;
    }
    if (!Credentials.isStrongEnough(_password.text)) {
      _passwordError = l.authPasswordTooShort;
      ok = false;
    }
    if (!ok) {
      setState(() {});
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).signUp(email, _password.text);
      if (mounted) widget.onCodeSent?.call(email);
    } on EmailTakenException {
      _fail(() => _emailError = l.authEmailTaken);
    } on WeakPasswordException {
      _fail(() => _passwordError = l.authPasswordTooShort);
    } on NoConnectionException {
      _fail(showOffline);
    } on TooManyRequestsException {
      _fail(() => _notice = l.commonTooManyRequests);
    } on Exception catch (e) {
      debugPrint('signUp failed: $e');
      _fail(() => _notice = l.commonUnexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _social(SocialProvider provider) async {
    final l = AppLocalizations.of(context);
    _clearErrors();
    try {
      await ref.read(authRepositoryProvider).signInWith(provider);
    } on NoConnectionException {
      _fail(showOffline);
    } on Exception catch (e) {
      debugPrint('social sign-in failed: $e');
      _fail(() => _notice = l.commonUnexpectedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ready =
        _accepted && _email.text.isNotEmpty && _password.text.isNotEmpty;
    return AuthLayout(
      title: l.signUpTitle,
      lead: AuthLead(l.signUpLead),
      onBack: widget.onBack,
      offline: offline,
      children: [
        AutofillGroup(
          child: Column(
            children: [
              AppTextField(
                label: l.authEmailLabel,
                controller: _email,
                hint: l.authEmailHint,
                forceLtr: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                error: _emailError,
                onChanged: (_) => _clearErrors(),
              ),
              const SizedBox(height: AuthGaps.field),
              PasswordField(
                label: l.authPasswordLabel,
                controller: _password,
                isNew: true,
                helper: l.authPasswordHelper,
                error: _passwordError,
                textInputAction: TextInputAction.done,
                onChanged: (_) => _clearErrors(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AuthGaps.field),
        AppCheckbox(
          value: _accepted,
          onChanged: (v) => setState(() => _accepted = v),
          label: LinkedText(
            text: l.authConsent,
            links: {
              l.authTerms: () => widget.onOpenTerms?.call(),
              l.authPrivacy: () => widget.onOpenPrivacy?.call(),
            },
          ),
        ),
        const SizedBox(height: AuthGaps.beforeButton),
        if (_notice != null) ...[
          NoticeBox(message: _notice!),
          const SizedBox(height: AuthGaps.between),
        ],
        AppButton(
          label: l.signUpButton,
          loading: _busy,
          onPressed: ready ? _submit : null,
        ),
        SocialButtons(onPressed: _social, enabled: _accepted && !_busy),
        const SizedBox(height: AuthGaps.beforeButton),
        Center(
          child: LinkedText(
            text: l.signUpHaveAccount,
            links: {l.signUpSignInLink: () => widget.onSignIn?.call()},
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/linked_text.dart';
import '../../core/widgets/notice_box.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/text_action.dart';
import 'data/auth_repository.dart';
import 'domain/credentials.dart';
import 'widgets/auth_layout.dart';
import 'widgets/social_buttons.dart';

/// Connexion: e-mail + password, or Google / Facebook. A successful
/// sign-in is picked up by the router (auth changes), which opens A6 or the
/// user's home. An account whose e-mail was never confirmed gets a new code
/// and goes to the code screen through [onNeedsCode].
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    this.onCreateAccount,
    this.onForgotPassword,
    this.onNeedsCode,
  });

  final VoidCallback? onCreateAccount;
  final ValueChanged<String>? onForgotPassword;
  final ValueChanged<String>? onNeedsCode;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with OfflineBanner {
  final _email = TextEditingController();
  final _password = TextEditingController();
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

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final email = Credentials.normalizeEmail(_email.text);
    _clearErrors();
    if (!Credentials.isEmail(email)) {
      setState(() => _emailError = l.authInvalidEmail);
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _passwordError = l.authWrongCredentials);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final auth = ref.read(authRepositoryProvider);
    try {
      await auth.signIn(email, _password.text);
    } on InvalidCredentialsException {
      _fail(() => _passwordError = l.authWrongCredentials);
    } on EmailNotConfirmedException {
      try {
        await auth.sendCode(email, CodePurpose.signUp);
        if (mounted) widget.onNeedsCode?.call(email);
      } on Exception {
        _fail(() => _notice = l.commonUnexpectedError);
      }
    } on NoConnectionException {
      _fail(showOffline);
    } on TooManyRequestsException {
      _fail(() => _notice = l.commonTooManyRequests);
    } on Exception catch (e) {
      debugPrint('signIn failed: $e');
      _fail(() => _notice = l.commonUnexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _fail(VoidCallback update) {
    if (mounted) setState(update);
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
    return AuthLayout(
      title: l.signInTitle,
      lead: AuthLead(l.signInLead),
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
                error: _passwordError,
                textInputAction: TextInputAction.done,
                onChanged: (_) => _clearErrors(),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextAction(
            label: l.signInForgot,
            onTap: () => widget.onForgotPassword?.call(
              Credentials.normalizeEmail(_email.text),
            ),
          ),
        ),
        if (_notice != null) ...[
          NoticeBox(message: _notice!),
          const SizedBox(height: AuthGaps.between),
        ],
        const SizedBox(height: Space.xs),
        AppButton(label: l.signInButton, loading: _busy, onPressed: _submit),
        SocialButtons(onPressed: _social, enabled: !_busy),
        const SizedBox(height: AuthGaps.beforeButton),
        Center(
          child: LinkedText(
            text: l.signInNoAccount,
            links: {l.signInCreateLink: () => widget.onCreateAccount?.call()},
          ),
        ),
      ],
    );
  }
}

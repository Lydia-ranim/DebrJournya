import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/notice_box.dart';
import '../../core/widgets/password_field.dart';
import 'data/auth_repository.dart';
import 'domain/credentials.dart';
import 'widgets/auth_layout.dart';

/// Nouveau mot de passe: shown after a recovery code (the user is already
/// signed in by it). Saves the password, then [onDone].
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen>
    with OfflineBanner {
  final _password = TextEditingController();
  String? _error;
  String? _notice;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _fail(VoidCallback update) {
    if (mounted) setState(update);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _error = null;
      _notice = null;
    });
    if (!Credentials.isStrongEnough(_password.text)) {
      setState(() => _error = l.authPasswordTooShort);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).updatePassword(_password.text);
      if (mounted) widget.onDone?.call();
    } on WeakPasswordException {
      _fail(() => _error = l.authPasswordTooShort);
    } on NoConnectionException {
      _fail(showOffline);
    } on Exception catch (e) {
      debugPrint('updatePassword failed: $e');
      _fail(() => _notice = l.commonUnexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthLayout(
      title: l.newPasswordTitle,
      lead: AuthLead(l.newPasswordLead),
      offline: offline,
      children: [
        PasswordField(
          label: l.authPasswordLabel,
          controller: _password,
          isNew: true,
          helper: l.authPasswordHelper,
          error: _error,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() => _error = null),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AuthGaps.beforeButton),
        if (_notice != null) ...[
          NoticeBox(message: _notice!),
          const SizedBox(height: AuthGaps.between),
        ],
        AppButton(
          label: l.newPasswordButton,
          loading: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}

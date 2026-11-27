import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/code_input.dart';
import '../../core/widgets/linked_text.dart';
import '../../core/widgets/notice_box.dart';
import '../../core/widgets/round_icon_button.dart';
import '../../core/widgets/status_banner.dart';
import '../../core/widgets/text_action.dart';
import 'data/auth_repository.dart';

/// A5 · Code: the 6-digit code e-mailed to [email], to confirm a new
/// account or to reset a password ([purpose]). Verifies through
/// [authRepositoryProvider] (which signs the user in); 3 tries per code,
/// resend after 60 s.
class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({
    super.key,
    required this.email,
    this.purpose = CodePurpose.signUp,
    this.onVerified,
    this.onChangeEmail,
    this.initialCode = '',
    this.resendAfter = const Duration(seconds: 60),
  });

  final String email;
  final CodePurpose purpose;
  final VoidCallback? onVerified;

  /// Back to the e-mail form (also the back button).
  final VoidCallback? onChangeEmail;

  /// Pre-filled digits (used by golden tests).
  final String initialCode;
  final Duration resendAfter;

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

enum _Problem { wrong, noTriesLeft, expired, tooMany, failed }

class _CodeScreenState extends ConsumerState<CodeScreen> {
  // Measured on the mockups (pt).
  static const _backPadding = EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0);
  static const _bannerPadding = EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0);
  static const _backToTitle = 16.0;
  static const _titleToLead = 9.0;
  static const _leadToCode = 32.5;
  static const _codeToTimer = 19.0;
  static const _timerToNotice = 19.0;
  static const _timerIcon = 18.0;
  static const _timerGap = 9.0;
  static const _buttonPadding = EdgeInsetsDirectional.fromSTEB(20, 12, 20, 40);
  static const _codeLength = 6;
  static const _triesPerCode = 3;
  static const _offlineFor = Duration(seconds: 4);

  late final _code = TextEditingController(text: widget.initialCode);
  late Duration _left = widget.resendAfter;
  Timer? _ticker;
  Timer? _offlineTimer;
  int _wrongTries = 0;
  _Problem? _problem;
  bool _busy = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _offlineTimer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _ticker?.cancel();
    _left = widget.resendAfter;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left -= const Duration(seconds: 1));
      if (_left <= Duration.zero) t.cancel();
    });
  }

  bool get _locked =>
      _problem == _Problem.noTriesLeft || _problem == _Problem.expired;

  bool get _canVerify => _code.text.length == _codeLength && !_busy && !_locked;

  void _showOffline() {
    _offlineTimer?.cancel();
    _offlineTimer = Timer(_offlineFor, () {
      if (mounted) setState(() => _offline = false);
    });
    setState(() => _offline = true);
  }

  Future<void> _verify() async {
    if (!_canVerify) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyCode(widget.email, _code.text, widget.purpose);
      if (!mounted) return;
      setState(() => _busy = false);
      widget.onVerified?.call();
    } on InvalidCodeException {
      if (!mounted) return;
      _wrongTries++;
      setState(() {
        _busy = false;
        _problem = _wrongTries >= _triesPerCode
            ? _Problem.noTriesLeft
            : _Problem.wrong;
        _code.clear();
      });
    } on CodeExpiredException {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _problem = _Problem.expired;
      });
    } on NoConnectionException {
      if (!mounted) return;
      setState(() => _busy = false);
      _showOffline();
    } catch (e) {
      debugPrint('auth failed: $e');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _problem = _Problem.failed;
      });
    }
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendCode(widget.email, widget.purpose);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _wrongTries = 0;
        _problem = null;
        _code.clear();
      });
      _startCountdown();
    } on NoConnectionException {
      if (!mounted) return;
      setState(() => _busy = false);
      _showOffline();
    } on TooManyRequestsException {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _problem = _Problem.tooMany;
      });
    } catch (e) {
      debugPrint('auth failed: $e');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _problem = _Problem.failed;
      });
    }
  }

  String _message(AppLocalizations l) => switch (_problem!) {
    _Problem.wrong => l.codeWrong(_triesPerCode - _wrongTries),
    _Problem.noTriesLeft => l.codeNoTriesLeft,
    _Problem.expired => l.codeExpired,
    _Problem.tooMany => l.commonTooManyRequests,
    _Problem.failed => l.commonUnexpectedError,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = context.type;
    final c = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // The address stays left to right inside Arabic text.
    final shown = '\u2066${widget.email}\u2069';
    final m = _left.inSeconds ~/ 60;
    final s = (_left.inSeconds % 60).toString().padLeft(2, '0');
    final time = '$m:$s';

    final timer = _left > Duration.zero
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.clock, size: _timerIcon, color: c.textSecondary),
              const SizedBox(width: _timerGap),
              Flexible(
                child: LinkedText(
                  text: l.codeResendIn(time),
                  links: const {},
                  emphasis: {time},
                  style: type.control.copyWith(
                    color: c.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: TextAction(
              label: l.codeResend,
              onTap: _busy ? null : _resend,
            ),
          );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _backPadding,
          child: RoundIconButton(
            icon: LucideIcons.chevronLeftDir,
            tooltip: l.commonBack,
            onPressed: widget.onChangeEmail,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: _backToTitle),
              Semantics(
                header: true,
                child: Text(l.codeTitle, style: type.display),
              ),
              const SizedBox(height: _titleToLead),
              LinkedText(
                text: '${l.codeSentToEmail(shown)} ${l.codeChangeEmail}',
                emphasis: {shown},
                links: {l.codeChangeEmail: () => widget.onChangeEmail?.call()},
                style: type.body,
              ),
              const SizedBox(height: _leadToCode),
              CodeInput(
                controller: _code,
                length: _codeLength,
                autofocus: widget.initialCode.isEmpty,
                enabled: !_locked,
                error: _problem == _Problem.wrong,
                semanticsLabel: l.codeFieldLabel,
                onChanged: (_) => setState(() {
                  if (_problem == _Problem.wrong) _problem = null;
                }),
                onCompleted: (_) => _verify(),
              ),
              const SizedBox(height: _codeToTimer),
              timer,
              const SizedBox(height: Space.md),
              Text(
                l.codeLinkHint,
                textAlign: TextAlign.center,
                style: type.caption,
              ),
              if (_problem != null) ...[
                const SizedBox(height: _timerToNotice),
                NoticeBox(message: _message(l)),
              ],
              const SizedBox(height: Space.xxl),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: SingleChildScrollView(child: body)),
                Padding(
                  padding: _buttonPadding,
                  child: AppButton(
                    label: l.codeVerify,
                    loading: _busy,
                    onPressed: _canVerify ? _verify : null,
                  ),
                ),
              ],
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: Padding(
                padding: _bannerPadding,
                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  child: _offline
                      ? StatusBanner(
                          icon: LucideIcons.wifiOff,
                          message: l.commonNoConnection,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

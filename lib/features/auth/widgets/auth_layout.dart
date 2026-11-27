import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/round_icon_button.dart';
import '../../../core/widgets/status_banner.dart';
import '../../mascot/jobby.dart';

/// Page frame shared by the sign-in screens, in the A4 style: optional back
/// button, Jobby, big title, lead, then the form ([children]) — all
/// scrollable so the keyboard never hides a field. The "Pas de connexion"
/// banner slides over the top when [offline].
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.children,
    this.lead,
    this.onBack,
    this.offline = false,
    this.showMascot = true,
  });

  final String title;
  final Widget? lead;
  final List<Widget> children;
  final VoidCallback? onBack;
  final bool offline;
  final bool showMascot;

  // Measured on the A4 mockup (pt).
  static const _backPadding = EdgeInsetsDirectional.fromSTEB(16, 16, 0, 0);
  static const _bannerPadding = EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0);
  static const _jobby = 74.0;
  static const _jobbyIndent = 4.0;
  static const _backToJobby = 4.0;
  static const _jobbyToTitle = 22.0;
  static const _titleToLead = 7.0;
  static const _leadToForm = 28.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final type = context.type;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null)
          Padding(
            padding: _backPadding,
            child: RoundIconButton(
              icon: LucideIcons.chevronLeftDir,
              tooltip: l.commonBack,
              onPressed: onBack,
            ),
          )
        else
          const SizedBox(height: Space.pageTop),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            Space.page,
            0,
            Space.page,
            Space.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showMascot) ...[
                if (onBack != null) const SizedBox(height: _backToJobby),
                const ExcludeSemantics(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: _jobbyIndent),
                    child: Jobby(size: _jobby, state: JobbyState.working),
                  ),
                ),
                const SizedBox(height: _jobbyToTitle),
              ] else
                const SizedBox(height: Space.xl),
              Semantics(header: true, child: Text(title, style: type.display)),
              if (lead != null) ...[
                const SizedBox(height: _titleToLead),
                lead!,
              ],
              const SizedBox(height: _leadToForm),
              ...children,
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(child: content),
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
                  child: offline
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

/// Lead paragraph in the A4 style.
class AuthLead extends StatelessWidget {
  const AuthLead(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.type.body.copyWith(height: 1.53));
}

/// Shows the offline banner for a few seconds (shared by the auth screens).
mixin OfflineBanner<T extends StatefulWidget> on State<T> {
  static const _showFor = Duration(seconds: 4);
  bool offline = false;
  Timer? _offlineTimer;

  void showOffline() {
    _offlineTimer?.cancel();
    _offlineTimer = Timer(_showFor, () {
      if (mounted) setState(() => offline = false);
    });
    setState(() => offline = true);
  }

  @override
  void dispose() {
    _offlineTimer?.cancel();
    super.dispose();
  }
}

/// Space between form blocks.
abstract final class AuthGaps {
  static const field = 18.0;
  static const beforeButton = 24.0;
  static const aroundDivider = 20.0;
  static const between = 12.0;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/storage/preferences.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/page_dots.dart';
import '../../core/widgets/text_action.dart';
import 'onboarding_art.dart';

/// A2 · Onboarding: three swipeable slides. "Passer" (slides 1–2) and
/// "Commencer" (slide 3) mark onboarding as seen and call [onDone].
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.onDone, this.initialPage = 0});

  final VoidCallback? onDone;

  /// Starting slide (used by golden tests).
  final int initialPage;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _count = 3;

  // Measured on the mockups (pt).
  static const _headerPadding = EdgeInsetsDirectional.fromSTEB(22, 16, 16, 0);
  static const _footerPadding = EdgeInsetsDirectional.fromSTEB(24, 0, 25, 44.5);
  static const _buttonWidth = 169.0;
  static const _art = 300.0;
  static const _artToTitle = 36.0;
  static const _titleToLead = 8.5;
  static const _textMargin = 30.0;
  // The slide body is centred slightly above the middle of the free space.
  static const _bodyLift = 5.0;

  late final PageController _pager = PageController(
    initialPage: widget.initialPage,
  );
  late int _page = widget.initialPage;

  bool get _last => _page == _count - 1;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(PrefKeys.onboardingSeen, true);
    widget.onDone?.call();
  }

  void _next() {
    if (_last) {
      _finish();
    } else {
      final reduce = MediaQuery.disableAnimationsOf(context);
      if (reduce) {
        _pager.jumpToPage(_page + 1);
      } else {
        _pager.nextPage(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slides = [
      (l.onboarding1Title, l.onboarding1Lead),
      (l.onboarding2Title, l.onboarding2Lead),
      (l.onboarding3Title, l.onboarding3Lead),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: _headerPadding,
              child: SizedBox(
                height: Sizes.button,
                child: BrandHeader(
                  trailing: _last
                      ? null
                      : TextAction(label: l.onboardingSkip, onTap: _finish),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pager,
                itemCount: _count,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) =>
                    _Slide(art: i, title: slides[i].$1, lead: slides[i].$2),
              ),
            ),
            Padding(
              padding: _footerPadding,
              child: Row(
                children: [
                  PageDots(
                    count: _count,
                    current: _page,
                    semanticsLabel: l.onboardingProgress(_page + 1, _count),
                  ),
                  const Spacer(),
                  AppButton(
                    width: _buttonWidth,
                    label: _last ? l.onboardingStart : l.onboardingNext,
                    icon: _last ? null : LucideIcons.chevronRightDir,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.art, required this.title, required this.lead});

  final int art;
  final String title;
  final String lead;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    return LayoutBuilder(
      builder: (context, box) {
        // Full size on a normal phone; shrinks on short or narrow screens.
        final artSize = math.min(
          _OnboardingScreenState._art,
          math.min(box.maxWidth - 2 * Space.page, box.maxHeight * 0.5),
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                _OnboardingScreenState._textMargin,
                0,
                _OnboardingScreenState._textMargin,
                _OnboardingScreenState._bodyLift,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OnboardingArt(slide: art, size: artSize),
                  const SizedBox(height: _OnboardingScreenState._artToTitle),
                  Text(title, style: type.hero, textAlign: TextAlign.center),
                  const SizedBox(height: _OnboardingScreenState._titleToLead),
                  Text(
                    lead,
                    style: type.leadLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

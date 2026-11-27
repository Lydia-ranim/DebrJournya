import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/loading_dots.dart';
import '../../core/widgets/wordmark.dart';
import '../mascot/jobby.dart';

/// A1 · Splash. Animated Jobby, wordmark, tagline and a loader while the app
/// starts. Calls [onReady] once [bootstrap] has finished and the splash has
/// been visible for at least [minDuration].
///
/// Layout follows `Docs/design/light/A1 · Splash.png` (390×844 reference).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.bootstrap,
    this.onReady,
    this.minDuration = const Duration(milliseconds: 1800),
  });

  /// Start-up work (session restore, settings…). Null = nothing to wait for.
  final Future<void>? bootstrap;

  /// Called once, when the app may leave the splash.
  final VoidCallback? onReady;

  final Duration minDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Reference measurements (pt) from the mockup.
  static const _jobbyBox = 153.5;
  // The case is centred with its notepad: shift the box right a little.
  static const _jobbyShift = 5.0;
  static const _wordmarkSize = 32.0;
  static const _taglineSize = 15.0;
  // Distance from the screen bottom to the centre of the loader dots.
  static const _dotsCentreFromBottom = 76.5;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else {
      _intro.forward();
    }
    _waitThenContinue();
  }

  Future<void> _waitThenContinue() async {
    await Future.wait([
      Future<void>.delayed(widget.minDuration),
      widget.bootstrap ?? Future<void>.value(),
    ]);
    if (mounted) widget.onReady?.call();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  /// Fade + slide-up for an element appearing between [start] and [end] (0–1).
  Widget _reveal({
    required double start,
    required double end,
    required Widget child,
    double slide = 8,
  }) {
    final curve = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, slide * (1 - curve.value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    final jobbyPop = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
    );

    final mascot = AnimatedBuilder(
      animation: jobbyPop,
      builder: (context, child) => Opacity(
        opacity: jobbyPop.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.8 + 0.2 * jobbyPop.value,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
      child: Transform.translate(
        offset: const Offset(_jobbyShift, 0),
        child: const Jobby(
          size: _jobbyBox,
          state: JobbyState.working,
          stillTime: 1.3,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        children: [
          Align(
            // Puts the group where the mockup has it (slightly above centre).
            alignment: const AlignmentDirectional(0, -0.175),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  mascot,
                  const SizedBox(height: 21),
                  _reveal(
                    start: 0.3,
                    end: 0.8,
                    child: const Wordmark(size: _wordmarkSize),
                  ),
                  const SizedBox(height: 19.5),
                  _reveal(
                    start: 0.45,
                    end: 0.95,
                    child: Text(
                      l10n.splashTagline,
                      textAlign: TextAlign.center,
                      style: appText(
                        size: _taglineSize,
                        weight: FontWeight.w500,
                        wght: 550,
                        height: 1.4,
                        letterSpacing: -0.07,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            // LoadingDots is 15 pt tall with the dots on its centre line.
            bottom: math.max(_dotsCentreFromBottom, bottomInset + 44) - 7.5,
            child: Center(
              child: _reveal(
                start: 0.7,
                end: 1,
                slide: 0,
                child: const LoadingDots(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Three dots that pulse in turn: the app's loading indicator (splash A1).
///
/// At rest (reduced motion) the dots are drawn exactly as in the mockup.
class LoadingDots extends StatefulWidget {
  const LoadingDots({
    super.key,
    this.dotSize = 7.5,
    this.spacing = 16,
    this.colors,
    this.period = const Duration(milliseconds: 1200),
  });

  /// Dot diameter.
  final double dotSize;

  /// Distance between dot centres.
  final double spacing;

  /// Dot colours, start to end. Defaults to the theme's loader colours.
  final List<Color>? colors;

  /// Time for the pulse to travel across all three dots.
  final Duration period;

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? context.colors.loaderDots;
    final still = MediaQuery.disableAnimationsOf(context);
    final width = widget.spacing * (colors.length - 1) + widget.dotSize;

    return Semantics(
      label: AppLocalizations.of(context).loadingLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width + widget.dotSize, // room for the pulse scale
          height: widget.dotSize * 2,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _DotsPainter(
                colors: colors,
                dotSize: widget.dotSize,
                spacing: widget.spacing,
                progress: still ? null : _controller.value,
                textDirection: Directionality.of(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({
    required this.colors,
    required this.dotSize,
    required this.spacing,
    required this.progress,
    required this.textDirection,
  });

  final List<Color> colors;
  final double dotSize;
  final double spacing;

  /// 0–1 through the loop, or null for the still mockup look.
  final double? progress;

  /// The wave travels in reading direction.
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final n = colors.length;
    final startX = size.width / 2 - spacing * (n - 1) / 2;
    final cy = size.height / 2;
    for (var i = 0; i < n; i++) {
      // Colours keep their visual order (dark → light) in both directions.
      final x = startX + spacing * i;
      final order = textDirection == TextDirection.ltr ? i : n - 1 - i;
      var scale = 1.0;
      var opacity = 1.0;
      final p = progress;
      if (p != null) {
        // Each dot peaks once per loop, a third of a period apart.
        final phase = (p - order / n) % 1.0;
        final wave = phase < 0.5 ? math.sin(phase / 0.5 * math.pi) : 0.0;
        scale = 1 + 0.35 * wave;
        opacity = 0.55 + 0.45 * wave;
      }
      canvas.drawCircle(
        Offset(x, cy),
        dotSize / 2 * scale,
        Paint()..color = colors[i].withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.progress != progress ||
      old.colors != colors ||
      old.textDirection != textDirection;
}

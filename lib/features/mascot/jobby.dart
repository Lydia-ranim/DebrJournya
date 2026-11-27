import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/l10n/app_localizations.dart';
import 'jobby_painter.dart';
import 'jobby_sim.dart';

export 'jobby_sim.dart' show JobbyState;

/// Jobby, the animated briefcase mascot and app logo.
///
/// [size] is the side of the 0–100 drawing box; the case itself spans 90% of
/// it and the notepad pokes out a little on the left. Tap to make it hop.
///
/// Animation stops (a still pose is shown) when [animate] is false or when
/// the platform asks for reduced motion.
class Jobby extends StatefulWidget {
  const Jobby({
    super.key,
    this.size = 150,
    this.state = JobbyState.idle,
    this.animate = true,
    this.interactive = true,
    this.stillTime = 0,
    this.seed = 7,
  });

  final double size;
  final JobbyState state;
  final bool animate;
  final bool interactive;

  /// Time (s) of the pose shown when not animating.
  final double stillTime;

  /// Random seed for blink timing.
  final int seed;

  @override
  State<Jobby> createState() => _JobbyState();
}

class _JobbyState extends State<Jobby> with SingleTickerProviderStateMixin {
  late final JobbySim _sim = JobbySim(state: widget.state, seed: widget.seed);
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(Jobby old) {
    super.didUpdateWidget(old);
    _sim.state = widget.state;
    _syncTicker();
  }

  bool get _shouldAnimate =>
      widget.animate && !MediaQuery.disableAnimationsOf(context);

  void _syncTicker() {
    if (_shouldAnimate) {
      if (!_ticker.isActive) {
        _last = Duration.zero;
        _ticker.start();
      }
    } else {
      if (_ticker.isActive) _ticker.stop();
      _sim.seek(widget.stillTime);
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _sim.tick(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget child = CustomPaint(
      size: Size.square(widget.size),
      painter: JobbyPainter(sim: _sim, dark: dark),
    );
    if (widget.interactive) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _sim.poke,
        child: child,
      );
    }
    return Semantics(
      image: true,
      label: AppLocalizations.of(context).mascotLabel,
      child: ExcludeSemantics(child: child),
    );
  }
}

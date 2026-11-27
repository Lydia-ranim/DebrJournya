import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// What Jobby is doing. Mirrors the states of the original prototype
/// (`Docs/design/mascot/pro (2).jsx`): au repos, prend des notes, endormi.
enum JobbyState { idle, working, sleeping }

/// Pose of the mascot for one frame, in the painter's 0–100 unit box.
@immutable
class JobbyPose {
  const JobbyPose({
    this.dx = 0,
    this.dy = 0,
    this.sx = 1,
    this.sy = 1,
    this.roll = 0,
    this.eyeOpen = 1,
    this.lookX = 0,
    this.lookY = 0,
    this.writing = 0,
    this.scribble = 0.75,
    this.penWiggle = 0,
    this.sleep = 0,
    this.time = 0,
  });

  /// Body offset (units). Negative [dy] is up.
  final double dx, dy;

  /// Squash and stretch around the bottom of the case.
  final double sx, sy;

  /// Tilt in radians around the face.
  final double roll;

  /// 1 = eyes open, 0 = closed (blink).
  final double eyeOpen;

  /// Pupil offset (units).
  final double lookX, lookY;

  /// 0–1: how much the pen is actively writing.
  final double writing;

  /// 0–1: progress of the line being written on the notepad.
  final double scribble;

  /// Small pen jitter while writing (units).
  final double penWiggle;

  /// 0–1: sleeping amount (closed eyes, "z").
  final double sleep;

  /// Seconds since start, for decorative loops (the floating "z").
  final double time;

  /// The resting pose used for static renders (launcher icon, reduced motion).
  static const still = JobbyPose(writing: 0, scribble: 0.75);
}

/// Drives Jobby's motion. Deterministic for a given [seed] so that tests and
/// generated assets are reproducible.
class JobbySim extends ChangeNotifier {
  JobbySim({JobbyState state = JobbyState.idle, int seed = 7})
    : _random = math.Random(seed) {
    _state = state;
    _nextBlink = 1.2 + _random.nextDouble() * 2.5;
    _pose = _compute();
  }

  final math.Random _random;
  late JobbyState _state;
  double _t = 0;

  // Smoothed blend values so state changes ease instead of snapping.
  double _writing = 0;
  double _sleep = 0;

  double _nextBlink = 2;
  double _blinkStart = -10;

  double _jumpStart = -10;
  static const _jumpDuration = 0.62;

  late JobbyPose _pose;

  /// When true (set by [seek]), body motion is frozen in a level pose.
  bool _still = false;

  JobbyPose get pose => _pose;
  JobbyState get state => _state;
  double get time => _t;

  set state(JobbyState value) {
    if (value == _state) return;
    _state = value;
  }

  /// Tap reaction: a little hop with squash and stretch.
  void poke() {
    if (_t - _jumpStart > _jumpDuration * 0.7) _jumpStart = _t;
  }

  /// Advances the simulation by [dt] seconds and notifies listeners.
  void tick(double dt) {
    _still = false;
    _t += dt.clamp(0, 0.05);
    final ease = 1 - math.exp(-dt * 6);
    _writing += ((_state == JobbyState.working ? 1 : 0) - _writing) * ease;
    _sleep += ((_state == JobbyState.sleeping ? 1 : 0) - _sleep) * ease;
    if (_t >= _nextBlink) {
      _blinkStart = _t;
      // Occasional double blink.
      _nextBlink =
          _t +
          (_random.nextDouble() < 0.2
              ? 0.28
              : 2.4 + _random.nextDouble() * 2.8);
    }
    _pose = _compute();
    notifyListeners();
  }

  /// Shows a still, level pose at time [t] (static renders, reduced motion).
  /// The notepad/pen still reflect the current state.
  void seek(double t) {
    _still = true;
    _t = t;
    _writing = _state == JobbyState.working ? 1 : 0;
    _sleep = _state == JobbyState.sleeping ? 1 : 0;
    _pose = _compute();
    notifyListeners();
  }

  JobbyPose _compute() {
    final t = _t;
    final awake = 1 - _sleep;

    // Breathing / idle bob. Slower and deeper while asleep.
    final period = 2.6 + 1.6 * _sleep;
    final b = math.sin(t * 2 * math.pi / period);
    var dy = -b * (1.1 + 0.4 * _sleep);
    var sx = 1 - 0.012 * b;
    var sy = 1 + 0.012 * b;
    var roll = math.sin(t * 0.9) * 0.012 * awake + 0.05 * _sleep;

    // Hop.
    final j = (t - _jumpStart) / _jumpDuration;
    if (j >= 0 && j <= 1) {
      if (j < 0.16) {
        final k = math.sin(j / 0.16 * math.pi);
        sx += 0.09 * k;
        sy -= 0.11 * k;
      } else if (j < 0.86) {
        final a = (j - 0.16) / 0.7;
        dy -= 13 * math.sin(a * math.pi);
        final s = math.sin(a * math.pi) * (1 - a);
        sx -= 0.05 * s;
        sy += 0.07 * s;
      } else {
        final k = math.sin((j - 0.86) / 0.14 * math.pi);
        sx += 0.07 * k;
        sy -= 0.08 * k;
      }
    }

    // Blink: quick close and open over 150 ms.
    var eyeOpen = 1.0;
    final bl = (t - _blinkStart) / 0.15;
    if (bl >= 0 && bl <= 1) eyeOpen = (2 * bl - 1).abs();
    eyeOpen = eyeOpen * awake;

    // Glance at the notepad now and then while writing.
    final glance = _writing * (0.5 + 0.5 * math.sin(t * 0.8)).clamp(0.0, 1.0);
    final lookX = -1.4 * glance;
    final lookY = 1.2 * glance;

    // Notepad line: grows while writing, rests at 75% otherwise (as in the jsx).
    final cycle = math.min(1.0, (t * 0.35) % 1.4);
    final scribble = cycle * _writing + (1 - _writing) * 0.75;
    final wiggle = _writing * math.sin(t * 22) * 0.8;

    if (_still) {
      dy = 0;
      sx = 1;
      sy = 1;
      roll = 0.05 * _sleep;
    }

    return JobbyPose(
      dy: dy,
      sx: sx,
      sy: sy,
      roll: roll,
      eyeOpen: eyeOpen,
      lookX: lookX,
      lookY: lookY,
      writing: _writing,
      scribble: scribble,
      penWiggle: wiggle,
      sleep: _sleep,
      time: t,
    );
  }
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../core/theme/app_colors.dart';
import 'jobby_sim.dart';

/// Draws "Jobby Pro", the briefcase mascot, in a 0–100 unit box scaled to the
/// widget size. Geometry for the case, handle, stitching, notepad and pen is
/// taken from `Docs/design/mascot/pro (2).jsx`; the face, glasses and bow tie
/// (from the prototype's missing `bot-avatars` library) are redrawn to match
/// the splash mockup `Docs/design/light/A1 · Splash.png`.
///
/// Drawing extends slightly outside the box (notepad on the left, hops), so
/// the parent should not clip it.
class JobbyPainter extends CustomPainter {
  JobbyPainter({required this.sim, this.dark = false}) : super(repaint: sim);

  /// Animation source. Its [JobbySim.pose] is read on every paint.
  final JobbySim sim;

  /// Dark theme: same artwork, slightly deeper contact shadow on the pad.
  final bool dark;

  // Palette of the artwork.
  static const _body = Palette.jobby;
  static const _bodyTop = Color(0xFF65886F);
  static const _bodyDeep = Color(0xFF42614C);
  static const _handleTop = Color(0xFF1C2A22);
  static const _handleBottom = Color(0xFF060B08);
  static const _rim = Color(0xFF121515);
  static const _lens = Color(0xFF8FA696);
  static const _pupil = Color(0xFF2E2A4A);
  static const _pupilDeep = Color(0xFF1C1933);
  static const _mouth = Color(0xFF1E1A3A);
  static const _paper = Color(0xFFFFFDF6);

  static final Path _bodyPath = Path()
    ..moveTo(14, 34)
    ..lineTo(86, 34)
    ..quadraticBezierTo(95, 34, 95, 43)
    ..lineTo(95, 77)
    ..quadraticBezierTo(95, 86, 86, 86)
    ..lineTo(14, 86)
    ..quadraticBezierTo(5, 86, 5, 77)
    ..lineTo(5, 43)
    ..quadraticBezierTo(5, 34, 14, 34)
    ..close();

  static final Path _handlePath = Path()
    ..moveTo(37, 37)
    ..lineTo(37, 27)
    ..quadraticBezierTo(37, 19, 45, 19)
    ..lineTo(55, 19)
    ..quadraticBezierTo(63, 19, 63, 27)
    ..lineTo(63, 37)
    ..lineTo(56.2, 37)
    ..lineTo(56.2, 28.8)
    ..quadraticBezierTo(56.2, 25.8, 53.4, 25.8)
    ..lineTo(46.6, 25.8)
    ..quadraticBezierTo(43.8, 25.8, 43.8, 28.8)
    ..lineTo(43.8, 37)
    ..close();

  static final Path _stitchPath = _dashed(
    Path()..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 39, 80, 42),
        const Radius.circular(6),
      ),
    ),
    dash: 2.2,
    gap: 2.2,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final pose = sim.pose;
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    // Whole-body transform: squash/stretch from the bottom centre, hop, tilt.
    canvas.translate(50 + pose.dx, 86 + pose.dy);
    canvas.scale(pose.sx, pose.sy);
    canvas.translate(-50, -86);
    canvas.translate(50, 60);
    canvas.rotate(pose.roll);
    canvas.translate(-50, -60);

    _paintHandle(canvas);
    _paintBody(canvas);
    canvas.drawPath(
      _stitchPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = const Color(0x59FFFFFF),
    );
    _paintGlasses(canvas, pose);
    _paintMouth(canvas, pose);
    _paintBowTie(canvas);
    _paintNotepad(canvas, pose);
    canvas.restore();

    if (pose.sleep > 0.02) _paintZzz(canvas, size, pose);
  }

  // ---------------------------------------------------------------- handle --

  void _paintHandle(Canvas canvas) {
    canvas.drawPath(
      _handlePath,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 19),
          const Offset(0, 37),
          const [_handleTop, _handleBottom],
        ),
    );
    // Soft green sheen along the outer edge of the grip.
    final sheen = Path()
      ..moveTo(38.4, 34)
      ..lineTo(38.4, 27.2)
      ..quadraticBezierTo(38.4, 20.4, 45.2, 20.4)
      ..lineTo(54.8, 20.4)
      ..quadraticBezierTo(61.6, 20.4, 61.6, 27.2)
      ..lineTo(61.6, 34);
    canvas.drawPath(
      sheen,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0x995E8069)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.45),
    );
  }

  // ------------------------------------------------------------------ body --

  void _paintBody(Canvas canvas) {
    // Shadow the case casts on the handle base.
    canvas.drawRect(
      const Rect.fromLTWH(36, 33, 28, 2.5),
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8),
    );

    canvas.drawPath(
      _bodyPath,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, 34),
          const Offset(0, 86),
          const [_bodyTop, _body, _bodyDeep],
          const [0, 0.4, 1],
        ),
    );

    canvas.save();
    canvas.clipPath(_bodyPath);

    // Plastic specular glow, left of the face.
    canvas.save();
    canvas.translate(21, 52);
    canvas.scale(1, 0.78);
    canvas.drawCircle(
      Offset.zero,
      27,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          27,
          const [
            Color(0xE6F4F8F1),
            Color(0x8CD6E4D9),
            Color(0x26C6D8CB),
            Color(0x00FFFFFF),
          ],
          const [0, 0.22, 0.55, 1],
        ),
    );
    canvas.restore();

    // Darker bottom-right falloff for volume.
    canvas.drawPath(
      _bodyPath,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(30, 46),
          80,
          const [Color(0x00000000), Color(0x00000000), Color(0x52000000)],
          const [0, 0.5, 1],
        ),
    );

    // Inner rounded edge (pillow look): blurred dark stroke inside the outline.
    canvas.drawPath(
      _bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = const Color(0x520A1710)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8),
    );

    // Light catching the top edge.
    canvas.drawLine(
      const Offset(14, 35.2),
      const Offset(86, 35.2),
      Paint()
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x40FFFFFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
    );
    canvas.restore();

    canvas.drawPath(
      _bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = const Color(0x55334D3B),
    );
  }

  // --------------------------------------------------------------- glasses --

  static const _lensL = Offset(38.4, 52);
  static const _lensR = Offset(61.6, 52);
  static const _lensR0 = 10.2; // glass radius, rim drawn on top

  void _paintGlasses(Canvas canvas, JobbyPose pose) {
    // Drop shadow of the frames on the case.
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    for (final c in [_lensL, _lensR]) {
      canvas.drawCircle(c.translate(0.6, 1.4), _lensR0 + 0.8, shadow);
    }

    for (final c in [_lensL, _lensR]) {
      final lens = Rect.fromCircle(center: c, radius: _lensR0);
      // Tinted glass.
      canvas.drawCircle(
        c,
        _lensR0,
        Paint()
          ..shader = ui.Gradient.radial(
            c.translate(-3, -3),
            _lensR0 * 1.4,
            const [Color(0xFFAEC1B3), _lens, Color(0xFF6E8675)],
            const [0, 0.55, 1],
          ),
      );

      canvas.save();
      canvas.clipPath(Path()..addOval(lens));
      _paintEye(canvas, c, pose);
      // Two diagonal glints across the glass.
      final glint = Paint()
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x8CFFFFFF);
      canvas.drawLine(
        c.translate(5.2, -9),
        c.translate(-1.6, 9),
        glint..strokeWidth = 1.5,
      );
      canvas.drawLine(
        c.translate(8.4, -6.6),
        c.translate(3.4, 6.8),
        glint..strokeWidth = 0.7,
      );
      canvas.restore();
    }

    // Rims and bridge.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = _rim;
    for (final c in [_lensL, _lensR]) {
      canvas.drawCircle(c, _lensR0 + 0.7, rim);
      // Subtle highlight on the top-left of each rim.
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: _lensR0 + 0.9),
        math.pi * 1.05,
        math.pi * 0.5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..strokeCap = StrokeCap.round
          ..color = const Color(0x44FFFFFF),
      );
    }
    final bridge = Path()
      ..moveTo(_lensL.dx + _lensR0 + 0.4, 48.6)
      ..quadraticBezierTo(50, 45.6, _lensR.dx - _lensR0 - 0.4, 48.6);
    canvas.drawPath(
      bridge,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = _rim,
    );
    // Hinge rivets.
    for (final p in const [Offset(27.6, 47.2), Offset(72.4, 47.2)]) {
      canvas.drawCircle(p, 0.85, Paint()..color = const Color(0xFFD9DEDA));
    }
  }

  void _paintEye(Canvas canvas, Offset c, JobbyPose pose) {
    final centre = c.translate(pose.lookX - 0.3, pose.lookY);
    final open = pose.eyeOpen;
    if (open > 0.08) {
      final rect = Rect.fromCenter(
        center: centre,
        width: 11.4,
        height: 13.6 * open,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topCenter,
            rect.bottomCenter,
            const [_pupil, _pupilDeep],
          ),
      );
    }
    if (open < 0.6) {
      // Closed eye: a soft curved lash line.
      final w = 5.2;
      final path = Path()
        ..moveTo(centre.dx - w, centre.dy + 0.5)
        ..quadraticBezierTo(
          centre.dx,
          centre.dy + 3.4,
          centre.dx + w,
          centre.dy + 0.5,
        );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..color = _pupilDeep.withValues(alpha: 1 - open / 0.6),
      );
    }
  }

  // ----------------------------------------------------------------- mouth --

  void _paintMouth(Canvas canvas, JobbyPose pose) {
    final asleep = pose.sleep;
    final dip = 2.6 * (1 - asleep) + 0.8 * asleep;
    final halfW = 7.0 - 2.5 * asleep;
    final path = Path()
      ..moveTo(50 - halfW, 66.4)
      ..quadraticBezierTo(50, 66.4 + dip * 2, 50 + halfW, 66.4);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.3
        ..strokeCap = StrokeCap.round
        ..color = _mouth,
    );
  }

  // --------------------------------------------------------------- bow tie --

  void _paintBowTie(Canvas canvas) {
    const cx = 50.0, cy = 76.2;
    Path wing(double s) => Path()
      ..moveTo(cx + s * 2.2, cy - 2.4)
      ..cubicTo(
        cx + s * 7,
        cy - 4.2,
        cx + s * 11.5,
        cy - 6.6,
        cx + s * 15.6,
        cy - 7.4,
      )
      ..cubicTo(
        cx + s * 14.6,
        cy - 2.6,
        cx + s * 14.6,
        cy + 2.6,
        cx + s * 15.6,
        cy + 7.6,
      )
      ..cubicTo(
        cx + s * 11.5,
        cy + 6.6,
        cx + s * 7,
        cy + 4.2,
        cx + s * 2.2,
        cy + 2.4,
      )
      ..close();

    for (final s in const [-1.0, 1.0]) {
      final w = wing(s);
      canvas.drawPath(
        w.shift(const Offset(0.4, 1.2)),
        Paint()
          ..color = const Color(0x47000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9),
      );
      // Base: dark at the knot, satin-lit toward the tips.
      canvas.drawPath(
        w,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(cx + s * 2, cy),
            Offset(cx + s * 15.6, cy),
            const [Color(0xFF1E2223), Color(0xFF454B4C), Color(0xFF303536)],
            const [0, 0.62, 1],
          ),
      );
      canvas.save();
      canvas.clipPath(w);
      // Upper and lower satin highlights following the folds.
      final sheen = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.9);
      canvas.drawPath(
        Path()
          ..moveTo(cx + s * 4, cy - 2.6)
          ..quadraticBezierTo(cx + s * 9, cy - 3.6, cx + s * 14.6, cy - 5.6),
        sheen
          ..strokeWidth = 2.4
          ..color = const Color(0xA6A2A9AA),
      );
      canvas.drawPath(
        Path()
          ..moveTo(cx + s * 4, cy + 2.2)
          ..quadraticBezierTo(cx + s * 9, cy + 3.4, cx + s * 14.4, cy + 5.4),
        sheen
          ..strokeWidth = 1.8
          ..color = const Color(0x738E9596),
      );
      // Darker crease through the middle of the wing.
      canvas.drawLine(
        Offset(cx + s * 3, cy + 0.2),
        Offset(cx + s * 14, cy + 0.4),
        Paint()
          ..strokeWidth = 1.4
          ..color = const Color(0x66101414)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
      );
      canvas.restore();
    }

    final knot = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(cx, cy), width: 5.4, height: 7.6),
      const Radius.circular(1.3),
    );
    canvas.drawRRect(
      knot,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, cy - 3.2),
          Offset(cx, cy + 3.2),
          const [Color(0xFF5A6061), Color(0xFF1E2223)],
        ),
    );
    canvas.drawLine(
      Offset(cx - 1.8, cy - 2.4),
      Offset(cx + 1.8, cy - 2.4),
      Paint()
        ..strokeWidth = 0.5
        ..color = const Color(0x55FFFFFF),
    );
  }

  // --------------------------------------------------- notepad + pen (jsx) --

  void _paintNotepad(Canvas canvas, JobbyPose pose) {
    canvas.save();
    canvas.translate(14, 78);
    canvas.rotate(0.22);

    RRect r(double x, double y, double w, double h, double rad) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          Radius.circular(rad),
        );

    canvas.drawRRect(
      r(-11.5, -12.5, 25, 30, 2.5),
      Paint()
        ..color = Color.fromRGBO(17, 20, 20, dark ? 0.35 : 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
    );
    canvas.drawRRect(r(-12.5, -14, 25, 30, 2.5), Paint()..color = _paper);
    canvas.drawRRect(
      r(-12.5, -14, 25, 30, 2.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = const Color(0x1F111414),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(-12.5, -14, 25, 5),
        topLeft: const Radius.circular(2.5),
        topRight: const Radius.circular(2.5),
      ),
      Paint()..color = Palette.soot,
    );
    final hole = Paint()..color = const Color(0xA6FFFFFF);
    for (var i = -9.0; i <= 9; i += 4.5) {
      canvas.drawCircle(Offset(i, -11.5), 0.9, hole);
    }

    // Ruled lines.
    final rule = Paint()
      ..strokeWidth = 0.7
      ..color = Palette.mist;
    for (var row = 0; row < 4; row++) {
      final y = -4 + row * 4.6;
      canvas.drawLine(Offset(-9, y), Offset(9, y), rule);
    }

    // Handwriting: a zig-zag scrawl; the third line grows while writing.
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Palette.soot;
    for (var row = 0; row < 3; row++) {
      final len = row == 2 ? 10 * pose.scribble : 16.0;
      if (len <= 0.1) continue;
      final y0 = -5.2 + row * 4.6;
      final path = Path()..moveTo(-8.5, y0);
      for (var x = 0.0; x <= len; x += 0.8) {
        path.lineTo(-8.5 + x, y0 - (math.sin(x * 1.9 + row)).abs() * 1.3);
      }
      canvas.drawPath(path, ink);
    }

    // Pen, writing at the end of the third line.
    final w = pose.writing;
    final px = -8.5 + 10 * pose.scribble * w + (1 - w) * 5;
    const py = 3.7 - 1.5;
    final wig = pose.penWiggle;
    canvas.translate(px + wig, py + wig.abs() * 0.5);
    canvas.rotate(-0.85);
    // Nib cone and tip.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(4, -1.4)
        ..lineTo(4, 1.4)
        ..close(),
      Paint()..color = const Color(0xFFD9D4C4),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(1.3, -0.45)
        ..lineTo(1.3, 0.45)
        ..close(),
      Paint()..color = Palette.ink,
    );
    // Barrel.
    canvas.drawRRect(
      r(4, -1.6, 17, 3.2, 1.4),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -1.6),
          const Offset(0, 1.6),
          const [Color(0xFF4A5556), Palette.soot, Color(0xFF141A1B)],
          const [0, 0.5, 1],
        ),
    );
    // Cap.
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(17, -1.6, 4.4, 3.2),
        topRight: const Radius.circular(1.4),
        bottomRight: const Radius.circular(1.4),
      ),
      Paint()..color = Palette.eucalyptus,
    );
    canvas.restore();
  }

  // ------------------------------------------------------------------- zzz --

  void _paintZzz(Canvas canvas, Size size, JobbyPose pose) {
    final k = size.width / 100;
    for (var i = 0; i < 3; i++) {
      final phase = ((pose.time * 0.45) + i / 3) % 1.0;
      final opacity = math.sin(phase * math.pi) * pose.sleep;
      final s = (2.6 + 2.2 * phase) * k;
      final origin = Offset(
        (80 + phase * 10 + i * 2) * k,
        (30 - phase * 22) * k,
      );
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..lineTo(origin.dx + s, origin.dy)
        ..lineTo(origin.dx, origin.dy + s)
        ..lineTo(origin.dx + s, origin.dy + s);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9 * k
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Palette.moss.withValues(alpha: opacity.clamp(0.0, 1.0)),
      );
    }
  }

  static Path _dashed(
    Path source, {
    required double dash,
    required double gap,
  }) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        out.addPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          Offset.zero,
        );
        d += dash + gap;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(JobbyPainter old) => old.sim != sim || old.dark != dark;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// The three A2 illustrations, drawn from simple shapes in a 300×300-pt
/// panel (coordinates measured on `Docs/design/light/A2 · Onboarding n 3.png`)
/// and scaled to [size]. Colours come from the theme, so dark mode follows.
/// Decorative: hidden from screen readers and never mirrored.
class OnboardingArt extends StatelessWidget {
  const OnboardingArt({super.key, required this.slide, this.size = _box});

  /// 0, 1 or 2.
  final int slide;
  final double size;

  static const _box = 300.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final badge = switch (slide) {
      0 => (const Offset(222, 222), 26.0, LucideIcons.mapPin),
      1 => (const Offset(250, 246), 28.0, LucideIcons.clock),
      _ => (const Offset(242, 62), 28.0, LucideIcons.sparkle),
    };
    final k = size / _box;
    final (centre, radius, icon) = badge;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _ArtPainter(slide, c))),
            // Badge: a round primary disc with an icon, placed by its centre.
            Align(
              alignment: Alignment(
                (centre.dx - _box / 2) / (_box / 2 - radius),
                (centre.dy - _box / 2) / (_box / 2 - radius),
              ),
              child: Container(
                width: radius * 2 * k,
                height: radius * 2 * k,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                ),
                child: slide == 2
                    ? _sparklePlus(radius * k, c.onPrimary)
                    : Icon(icon, size: radius * 0.96 * k, color: c.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four-point star with a small bold plus at its lower end corner, as drawn
/// on the mockup (no single Lucide icon has both). The plus is two bars so
/// its stroke matches the star's.
Widget _sparklePlus(double radius, Color color) {
  final star = radius * 0.66;
  final arm = radius * 0.24;
  final stroke = radius * 0.08;
  Widget bar(double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(stroke / 2),
    ),
  );
  return Stack(
    alignment: Alignment.center,
    children: [
      Transform.translate(
        offset: Offset(-radius * 0.02, -radius * 0.1),
        child: Icon(LucideIcons.sparkle, size: star, color: color),
      ),
      Transform.translate(
        offset: Offset(radius * 0.27, radius * 0.25),
        child: Stack(
          alignment: Alignment.center,
          children: [bar(arm, stroke), bar(stroke, arm)],
        ),
      ),
    ],
  );
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.slide, this.c);

  final int slide;
  final AppColors c;

  static const _panelRadius = 32.0;

  late Canvas _canvas;

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    canvas.save();
    canvas.scale(size.width / 300);
    final panel = slide == 1 ? c.infoSoft : c.greenSoft;
    _rrect(const Rect.fromLTWH(0, 0, 300, 300), _panelRadius, panel);
    switch (slide) {
      case 0:
        _jobCards();
      case 1:
        _weekGrid();
      default:
        _cvSheet();
    }
    canvas.restore();
  }

  // Slide 1: two tilted job cards and a blue disc.
  void _jobCards() {
    _canvas.drawCircle(const Offset(269, 35), 45, Paint()..color = c.blueTile);
    _jobCard(const Offset(127.75, 96.75), -6.3);
    _jobCard(const Offset(173.5, 175), 4.0);
  }

  void _jobCard(Offset centre, double degrees) {
    const w = 196.0, h = 82.0;
    _canvas.save();
    _canvas.translate(centre.dx, centre.dy);
    _canvas.rotate(degrees * math.pi / 180);
    _canvas.translate(-w / 2, -h / 2);
    _card(const Rect.fromLTWH(0, 0, w, h), 15, c.surface);
    _bar(const Rect.fromLTWH(15, 12, 119, 9), c.primary);
    _bar(const Rect.fromLTWH(16, 29, 80, 6), c.skeleton);
    _bar(const Rect.fromLTWH(18, 45, 54, 20), c.blueTile);
    _bar(const Rect.fromLTWH(78, 45, 40, 20), c.greenTile);
    _canvas.restore();
  }

  // Slide 2: a week of availability cells (7 days × 3 slots).
  void _weekGrid() {
    const card = Rect.fromLTWH(31, 71.5, 238, 156.5);
    _card(card, 16, c.surface);
    _bar(const Rect.fromLTWH(47, 88, 100, 10), c.primary);
    const pattern = ['1011001', '0110100', '1100110'];
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 7; col++) {
        final cell = Rect.fromLTWH(47.5 + col * 30, 112.5 + row * 35, 24, 29);
        final on = pattern[row][col] == '1';
        _rrect(cell, 7, on ? c.brandAccent : c.surface);
        if (!on) _stroke(cell.deflate(0.5), 6.5, c.line);
      }
    }
  }

  // Slide 3: a CV sheet with a photo, a name and two sections.
  void _cvSheet() {
    _card(const Rect.fromLTWH(55, 30, 190, 240), 10, c.paper, border: false);
    _canvas.drawCircle(const Offset(91, 66), 18, Paint()..color = c.blueTile);
    _bar(const Rect.fromLTWH(119, 55, 90, 9), c.primary);
    _bar(const Rect.fromLTWH(119, 70, 60, 7), c.skeleton);
    for (final top in const [102.0, 181.0]) {
      _bar(Rect.fromLTWH(73, top, 50, 7), c.brandAccent);
      const widths = [150.0, 130.0, 160.0, 110.0];
      for (var i = 0; i < widths.length; i++) {
        _bar(Rect.fromLTWH(73, top + 14 + i * 14, widths[i], 7), c.skeleton);
      }
    }
  }

  void _card(Rect r, double radius, Color fill, {bool border = true}) {
    final shape = RRect.fromRectAndRadius(r, Radius.circular(radius));
    _canvas.drawRRect(
      shape.shift(const Offset(0, 10)),
      Paint()
        ..color = c.shadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    _canvas.drawRRect(shape, Paint()..color = fill);
    if (border) _stroke(r.deflate(0.5), radius - 0.5, c.line);
  }

  void _bar(Rect r, Color color) => _rrect(r, r.height / 2, color);

  void _rrect(Rect r, double radius, Color color) => _canvas.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(radius)),
    Paint()..color = color,
  );

  void _stroke(Rect r, double radius, Color color) => _canvas.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(radius)),
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );

  @override
  bool shouldRepaint(_ArtPainter old) => old.slide != slide || old.c != c;
}

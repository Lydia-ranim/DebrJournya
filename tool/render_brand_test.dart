// Renders the static Jobby logo PNGs used for the Android launcher icon and
// the native launch screen, from the same painter as the in-app mascot.
//
// Regenerate after changing the mascot:
//   flutter test --update-goldens tool/render_brand_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// Lives in tool/ (not test/) so it never runs with the normal test suite.
import 'package:debrjournya/features/mascot/jobby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/helpers.dart';

/// Centre of the artwork's visible bounds in the 0–100 box (case + notepad).
const _artCentre = Offset(46.5, 58);

/// Paints Jobby centred on its visible artwork, [width] = case + notepad span.
Widget _logo(Size canvas, double artWidth, {Color? background}) {
  // The artwork spans ~97 units horizontally (notepad edge to case edge).
  final box = artWidth / 0.97;
  final k = box / 100;
  final shift = Offset((50 - _artCentre.dx) * k, (50 - _artCentre.dy) * k);
  return ColoredBox(
    color: background ?? Colors.transparent,
    child: Center(
      child: Transform.translate(
        offset: shift,
        child: Jobby(
          size: box,
          state: JobbyState.working,
          animate: false,
          interactive: false,
          stillTime: 1.3,
        ),
      ),
    ),
  );
}

void main() {
  Future<void> render(
    WidgetTester tester,
    String file, {
    required double side,
    required double artWidth,
    Color? background,
  }) async {
    // Golden frames paint at 2×, so lay out at half the output size.
    final size = Size.square(side / 2);
    useSurface(tester, size);
    await tester.pumpWidget(
      harness(_logo(size, artWidth / 2, background: background), frame: size),
    );
    await expectLater(
      find.byKey(goldenKey),
      matchesGoldenFile('../assets/brand/$file'),
    );
  }

  testWidgets('adaptive icon foreground (108dp canvas, 66dp safe zone)', (
    tester,
  ) async {
    await render(tester, 'icon_foreground.png', side: 1024, artWidth: 520);
  });

  testWidgets('legacy icon (cream square)', (tester) async {
    await render(
      tester,
      'icon_legacy.png',
      side: 1024,
      artWidth: 800,
      background: const Color(0xFFFAF8F2),
    );
  });

  testWidgets('native splash, Android < 12 (same size as the A1 mascot)', (
    tester,
  ) async {
    // 4× density asset; the A1 artwork is ~146 pt wide → 584 px.
    await render(tester, 'splash_logo.png', side: 640, artWidth: 584);
  });

  testWidgets('native splash, Android 12+ (fits the 192dp icon circle)', (
    tester,
  ) async {
    // 288dp × 4 = 1152 px canvas; circle mask Ø 768 px.
    await render(tester, 'splash_android12.png', side: 1152, artWidth: 580);
  });
}

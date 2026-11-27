import 'package:debrjournya/features/mascot/jobby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Box size that puts Jobby at the same scale as the A1 splash mockup
/// (the case spans 276 px at @2x → 90 units = 138 pt → box ≈ 153.5 pt).
const _splashBox = 153.5;

void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpJobby(
    WidgetTester tester, {
    required JobbyState state,
    Brightness brightness = Brightness.light,
    double stillTime = 0,
  }) async {
    const area = Size(190, 190);
    useSurface(tester, area);
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) => ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Jobby(
                size: _splashBox,
                state: state,
                animate: false,
                stillTime: stillTime,
              ),
            ),
          ),
        ),
        brightness: brightness,
        frame: area,
      ),
    );
  }

  for (final state in JobbyState.values) {
    testWidgets('Jobby ${state.name} (light)', (tester) async {
      await pumpJobby(tester, state: state, stillTime: 1.3);
      await expectLater(
        find.byKey(goldenKey),
        matchesGoldenFile('jobby_${state.name}_light.png'),
      );
    });
  }

  testWidgets('Jobby working (dark)', (tester) async {
    await pumpJobby(
      tester,
      state: JobbyState.working,
      brightness: Brightness.dark,
      stillTime: 1.3,
    );
    await expectLater(
      find.byKey(goldenKey),
      matchesGoldenFile('jobby_working_dark.png'),
    );
  });
}

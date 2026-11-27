import 'package:debrjournya/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  final cases = <String, (Locale, Brightness)>{
    'splash_fr_light': (const Locale('fr'), Brightness.light),
    'splash_fr_dark': (const Locale('fr'), Brightness.dark),
    'splash_ar_light': (const Locale('ar'), Brightness.light),
    'splash_ar_dark': (const Locale('ar'), Brightness.dark),
  };

  cases.forEach((name, config) {
    testWidgets(name, (tester) async {
      useSurface(tester, mockupSize);
      await tester.pumpWidget(
        harness(
          const SplashScreen(),
          locale: config.$1,
          brightness: config.$2,
          disableAnimations: true,
          frame: mockupSize,
        ),
      );
      await tester.pump();
      await expectLater(find.byKey(goldenKey), matchesGoldenFile('$name.png'));
      // Let the splash's minimum-duration timer finish.
      await tester.pump(const Duration(seconds: 2));
    });
  });
}

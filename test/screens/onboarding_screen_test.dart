import 'package:debrjournya/core/storage/preferences.dart';
import 'package:debrjournya/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(resetPrefs);

  for (var i = 0; i < 3; i++) {
    screenGoldens(
      'a2_onboarding_${i + 1}',
      () => OnboardingScreen(initialPage: i),
    );
  }
  robustnessTests('A2', () => const OnboardingScreen());
  robustnessTests(
    'A2 last slide',
    () => const OnboardingScreen(initialPage: 2),
  );

  testWidgets('Suivant walks through the slides, then Commencer finishes', (
    tester,
  ) async {
    var done = 0;
    await tester.pumpWidget(harness(OnboardingScreen(onDone: () => done++)));
    expect(find.text('Trouve un job flexible'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Remplis tes créneaux, vite'), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Construis ton CV'), findsOneWidget);
    // Last slide: no "Passer", the button says "Commencer".
    expect(find.text('Passer'), findsNothing);
    expect(find.text('Suivant'), findsNothing);

    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
    expect(done, 1);
    expect(testPrefs!.getBool(PrefKeys.onboardingSeen), isTrue);
  });

  testWidgets('Passer finishes right away', (tester) async {
    var done = 0;
    await tester.pumpWidget(harness(OnboardingScreen(onDone: () => done++)));
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(done, 1);
    expect(testPrefs!.getBool(PrefKeys.onboardingSeen), isTrue);
  });

  testWidgets('swiping moves to the next slide (leftwards in French)', (
    tester,
  ) async {
    await tester.pumpWidget(harness(const OnboardingScreen()));
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Remplis tes créneaux, vite'), findsOneWidget);
  });

  testWidgets('in Arabic the slides move the other way', (tester) async {
    await tester.pumpWidget(
      harness(const OnboardingScreen(), locale: const Locale('ar')),
    );
    await tester.fling(find.byType(PageView), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('املأ أوقات فراغك بسرعة'), findsOneWidget);
  });

  testWidgets('page dots announce the position', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(harness(const OnboardingScreen(initialPage: 1)));
    expect(find.bySemanticsLabel('Page 2 sur 3'), findsOneWidget);
    semantics.dispose();
  });
}

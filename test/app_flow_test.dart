// The real app (router, storage, locale) driven end to end.
import 'package:debrjournya/app.dart';
import 'package:debrjournya/core/router/app_router.dart';
import 'package:debrjournya/core/storage/preferences.dart';
import 'package:debrjournya/core/widgets/coming_soon_screen.dart';
import 'package:debrjournya/features/language/language_screen.dart';
import 'package:debrjournya/features/onboarding/onboarding_screen.dart';
import 'package:debrjournya/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Advances time through page transitions. (pumpAndSettle would never
/// return: the animated mascot on some screens keeps moving.)
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _app() => ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs!)],
  child: const DebrJournyaApp(),
);

Future<void> _passSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await _settle(tester);
}

void main() {
  testWidgets(
    'first launch: splash → language → onboarding → phone, in Arabic',
    (tester) async {
      await resetPrefs();
      await tester.pumpWidget(_app());
      expect(find.byType(SplashScreen), findsOneWidget);

      await _passSplash(tester);
      expect(find.byType(LanguageScreen), findsOneWidget);

      await tester.tap(find.text('العربية'));
      await _settle(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      // The whole app switched to Arabic, right to left.
      expect(find.text('اعثر على عمل مرن'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(OnboardingScreen))),
        TextDirection.rtl,
      );

      await tester.tap(find.text('تخطٍّ'));
      await _settle(tester);
      final coming = tester.widget<ComingSoonScreen>(
        find.byType(ComingSoonScreen),
      );
      expect(coming.routeName, Routes.phone);
      expect(testPrefs!.getString(PrefKeys.languageCode), 'ar');
      expect(testPrefs!.getBool(PrefKeys.onboardingSeen), isTrue);
    },
  );

  testWidgets('language chosen but onboarding not finished: back to A2', (
    tester,
  ) async {
    await resetPrefs({PrefKeys.languageCode: 'fr'});
    await tester.pumpWidget(_app());
    await _passSplash(tester);
    expect(find.byType(LanguageScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('returning user skips language and onboarding', (tester) async {
    await resetPrefs({
      PrefKeys.languageCode: 'fr',
      PrefKeys.onboardingSeen: true,
    });
    await tester.pumpWidget(_app());
    await _passSplash(tester);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.text('Bientôt disponible'), findsOneWidget);
  });
}

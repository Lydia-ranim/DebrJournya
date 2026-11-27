import 'package:debrjournya/core/l10n/locale_provider.dart';
import 'package:debrjournya/core/storage/preferences.dart';
import 'package:debrjournya/features/language/language_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(resetPrefs);

  screenGoldens('a3_language', () => const LanguageScreen());
  robustnessTests('A3', () => const LanguageScreen());

  testWidgets('shows both titles and both cards in their own language', (
    tester,
  ) async {
    await tester.pumpWidget(harness(const LanguageScreen()));
    expect(find.text('Choisis ta langue'), findsOneWidget);
    expect(find.text('اختر لغتك'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    // The Arabic card is laid out right-to-left even on a French screen.
    final arCtx = tester.element(find.text('العربية'));
    expect(Directionality.of(arCtx), TextDirection.rtl);
  });

  testWidgets('the lead follows the current app language', (tester) async {
    await tester.pumpWidget(
      harness(const LanguageScreen(), locale: const Locale('ar')),
    );
    expect(find.text('يمكنك تغييرها في أي وقت من الإعدادات.'), findsOneWidget);
  });

  for (final (label, code) in [('Français', 'fr'), ('العربية', 'ar')]) {
    testWidgets('tapping $label saves "$code" and continues', (tester) async {
      var continued = 0;
      await tester.pumpWidget(
        harness(LanguageScreen(onChosen: () => continued++)),
      );
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(continued, 1);
      expect(testPrefs!.getString(PrefKeys.languageCode), code);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(LanguageScreen)),
      );
      expect(container.read(localeProvider), Locale(code));
    });
  }

  testWidgets('a saved language is restored on the next launch', (
    tester,
  ) async {
    await resetPrefs({PrefKeys.languageCode: 'ar'});
    await tester.pumpWidget(harness(const LanguageScreen()));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(LanguageScreen)),
    );
    expect(container.read(localeProvider), const Locale('ar'));
  });
}

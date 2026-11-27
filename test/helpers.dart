import 'dart:convert';
import 'dart:io';

import 'package:debrjournya/core/l10n/app_localizations.dart';
import 'package:debrjournya/core/storage/preferences.dart';
import 'package:debrjournya/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mockups are 390×844 pt exported at @2x (780×1688 px). Scrolling screens
/// are exported full length (e.g. B4 is 780×2840): pass their height.
const mockupSize = Size(390, 844);

/// Loads the bundled fonts (and the icon font) so goldens show real text.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load(AppFonts.latin, ['assets/fonts/Manrope-Variable.ttf']);
  await load(AppFonts.arabic, [
    'assets/fonts/IBMPlexSansArabic-Medium.ttf',
    'assets/fonts/IBMPlexSansArabic-Bold.ttf',
  ]);
  // Package fonts are registered as "packages/<package>/<family>".
  await load('packages/lucide_icons_flutter/Lucide', [
    '${_packageRoot('lucide_icons_flutter')}/assets/lucide.ttf',
  ]);
}

String _packageRoot(String name) {
  final config = jsonDecode(
    File('.dart_tool/package_config.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final pkg = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((p) => p['name'] == name);
  return Uri.parse(pkg['rootUri'] as String).toFilePath();
}

/// Device storage for tests; set by [resetPrefs] (call it in `setUp` for any
/// screen that reads providers backed by storage).
SharedPreferences? testPrefs;

Future<void> resetPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  testPrefs = await SharedPreferences.getInstance();
}

const goldenKey = ValueKey('golden');

/// Golden captures are taken at 1 px per logical pixel, so the surface is
/// sized at @2x and [goldenFrame] scales a [size]-sized layout up by 2. The
/// resulting PNG has the same pixel size as the @2x mockup exports.
void useSurface(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size * 2;
  addTearDown(tester.view.reset);
}

/// Lays [child] out at [size] logical pixels and paints it at 2×.
Widget goldenFrame(Size size, Widget child) {
  return RepaintBoundary(
    key: goldenKey,
    child: SizedBox.fromSize(
      size: size * 2,
      child: FittedBox(
        child: SizedBox.fromSize(
          size: size,
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: size,
                devicePixelRatio: 2,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Wraps [child] in a themed, localised app inside a [ProviderScope] whose
/// device storage is [testPrefs] (call [resetPrefs] in `setUp`).
Widget harness(
  Widget child, {
  Locale locale = const Locale('fr'),
  Brightness brightness = Brightness.light,
  bool disableAnimations = false,
  double textScale = 1,
  Size? frame,
  List<Override> overrides = const [],
}) {
  final home = frame == null ? child : goldenFrame(frame, child);
  return ProviderScope(
    overrides: [
      if (testPrefs != null)
        sharedPreferencesProvider.overrideWithValue(testPrefs!),
      ...overrides,
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark(),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: c!,
      ),
      home: home,
    ),
  );
}

/// The four variants every screen is checked in.
const goldenVariants = <String, (Locale, Brightness)>{
  'fr_light': (Locale('fr'), Brightness.light),
  'fr_dark': (Locale('fr'), Brightness.dark),
  'ar_light': (Locale('ar'), Brightness.light),
  'ar_dark': (Locale('ar'), Brightness.dark),
};

/// Golden tests for one screen in FR/AR × light/dark, written to
/// `goldens/<name>_<variant>.png` next to the calling test (screen tests
/// live in `test/screens/`), at the mockup's pixel size.
/// [height] is the mockup height in pt (its PNG height / 2).
void screenGoldens(
  String name,
  Widget Function() build, {
  double height = 844,
  Future<void> Function(WidgetTester tester)? before,
}) {
  final size = Size(390, height);
  goldenVariants.forEach((variant, config) {
    testWidgets('$name $variant', (tester) async {
      await resetPrefs();
      useSurface(tester, size);
      await tester.pumpWidget(
        harness(
          build(),
          locale: config.$1,
          brightness: config.$2,
          disableAnimations: true,
          frame: size,
        ),
      );
      await tester.pumpAndSettle();
      if (before != null) await before(tester);
      await expectLater(
        find.byKey(goldenKey),
        matchesGoldenFile('goldens/${name}_$variant.png'),
      );
    });
  });
}

/// Checks that a screen lays out without overflow or exceptions on a small
/// phone (320×640) with large text (×1.3), in French and Arabic.
void robustnessTests(String name, Widget Function() build) {
  for (final locale in const [Locale('fr'), Locale('ar')]) {
    testWidgets(
      '$name fits a small phone with large text (${locale.languageCode})',
      (tester) async {
        await resetPrefs();
        tester.view.devicePixelRatio = 2;
        tester.view.physicalSize = const Size(640, 1280);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          harness(
            build(),
            locale: locale,
            textScale: 1.3,
            disableAnimations: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}

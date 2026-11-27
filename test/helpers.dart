import 'dart:io';

import 'package:debrjournya/core/l10n/app_localizations.dart';
import 'package:debrjournya/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mockups are 390×844 pt exported at @2x (780×1688 px).
const mockupSize = Size(390, 844);

/// Loads the bundled fonts so goldens show real text instead of boxes.
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

/// Wraps [child] in a themed, localised app.
Widget harness(
  Widget child, {
  Locale locale = const Locale('fr'),
  Brightness brightness = Brightness.light,
  bool disableAnimations = false,
  Size? frame,
}) {
  final home = frame == null ? child : goldenFrame(frame, child);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    builder: disableAnimations
        ? (context, c) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: c!,
          )
        : null,
    home: home,
  );
}

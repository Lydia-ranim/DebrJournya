import 'package:debrjournya/app.dart';
import 'package:debrjournya/core/widgets/loading_dots.dart';
import 'package:debrjournya/features/mascot/jobby.dart';
import 'package:debrjournya/features/mascot/jobby_sim.dart';
import 'package:debrjournya/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('Splash (A1)', () {
    testWidgets('shows the wordmark, French tagline, mascot and loader', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(harness(const SplashScreen()));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('DebrJournya', findRichText: true), findsOneWidget);
      expect(
        find.text('Le job qui s’adapte à ton emploi du temps'),
        findsOneWidget,
      );
      expect(find.byType(Jobby), findsOneWidget);
      expect(find.byType(LoadingDots), findsOneWidget);
      expect(find.bySemanticsLabel('Jobby, la mascotte'), findsOneWidget);
      expect(find.bySemanticsLabel('Chargement'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('is right-to-left in Arabic, wordmark stays Latin LTR', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(const SplashScreen(), locale: const Locale('ar')),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('عمل يناسب جدولك الزمني'), findsOneWidget);
      final ctx = tester.element(find.byType(LoadingDots));
      expect(Directionality.of(ctx), TextDirection.rtl);
      final wordmark = tester.widget<RichText>(
        find.text('DebrJournya', findRichText: true),
      );
      expect(wordmark.textDirection, TextDirection.ltr);
    });

    testWidgets('calls onReady after bootstrap and the minimum duration', (
      tester,
    ) async {
      var ready = 0;
      await tester.pumpWidget(
        harness(
          SplashScreen(
            bootstrap: Future<void>.delayed(const Duration(seconds: 3)),
            minDuration: const Duration(seconds: 1),
            onReady: () => ready++,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      expect(ready, 0, reason: 'bootstrap is still running');
      await tester.pump(const Duration(seconds: 2));
      expect(ready, 1);
    });

    testWidgets('reduced motion: no entrance animation, content visible', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(const SplashScreen(), disableAnimations: true),
      );
      await tester.pump();
      final opacities = tester
          .widgetList<Opacity>(
            find.descendant(
              of: find.byType(SplashScreen),
              matching: find.byType(Opacity),
            ),
          )
          .map((o) => o.opacity);
      expect(opacities, everyElement(1.0));
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group('Jobby', () {
    testWidgets('tap makes it hop', (tester) async {
      await tester.pumpWidget(harness(const Center(child: Jobby())));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byType(Jobby));
      // ~260 ms of real 60 fps frames (the sim clamps long frames).
      for (var i = 0; i < 16; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final painter = tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(Jobby),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter!;
      // ignore: avoid_dynamic_calls
      final pose = (painter as dynamic).sim.pose as JobbyPose;
      expect(pose.dy, lessThan(-5), reason: 'mid-air after a tap');
    });

    test('simulation is deterministic and states blend in', () {
      final a = JobbySim(state: JobbyState.working, seed: 3);
      final b = JobbySim(state: JobbyState.working, seed: 3);
      for (var i = 0; i < 120; i++) {
        a.tick(1 / 60);
        b.tick(1 / 60);
      }
      expect(a.pose.dy, b.pose.dy);
      expect(a.pose.writing, greaterThan(0.9));

      a.state = JobbyState.sleeping;
      for (var i = 0; i < 120; i++) {
        a.tick(1 / 60);
      }
      expect(a.pose.sleep, greaterThan(0.9));
      expect(a.pose.eyeOpen, lessThan(0.1));
    });
  });

  test('locale: Arabic phones get Arabic, everything else French', () {
    const supported = [Locale('fr'), Locale('ar')];
    expect(
      resolveLocale(const Locale('ar', 'DZ'), supported),
      const Locale('ar'),
    );
    expect(
      resolveLocale(const Locale('en', 'US'), supported),
      const Locale('fr'),
    );
    expect(resolveLocale(null, supported), const Locale('fr'));
  });
}

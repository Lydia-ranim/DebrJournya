import 'package:debrjournya/core/widgets/app_button.dart';
import 'package:debrjournya/features/auth/code_screen.dart';
import 'package:debrjournya/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _email = 'amina@exemple.com';

Future<void> _wait(WidgetTester tester, [int ms = 1000]) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

List<Override> _auth(FakeAuthRepository repo) => [
  authRepositoryProvider.overrideWithValue(repo),
];

Future<void> _type(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField), code);
  await tester.pump();
}

void main() {
  setUpAll(loadAppFonts);
  setUp(resetPrefs);

  // Mockup: 4 digits typed, the 5th box active, 0:42 left.
  screenGoldens(
    'a5_code',
    () => const CodeScreen(
      email: _email,
      initialCode: '4821',
      resendAfter: Duration(seconds: 42),
    ),
    before: (tester) async {
      await tester.tap(find.byType(TextField));
      await tester.pump();
    },
  );

  screenGoldens(
    'a5_code_wrong',
    () => const CodeScreen(email: _email, resendAfter: Duration(seconds: 42)),
    overrides: () => _auth(FakeAuthRepository(delay: Duration.zero)),
    before: (tester) async {
      await _type(tester, '111111');
      await tester.pump();
      await tester.pump();
    },
  );

  robustnessTests(
    'A5',
    () => const CodeScreen(email: _email, initialCode: '4821'),
  );

  testWidgets('a recovery code is checked as a recovery', (tester) async {
    final repo = FakeAuthRepository(delay: Duration.zero);
    var verified = 0;
    await tester.pumpWidget(
      harness(
        CodeScreen(
          email: _email,
          purpose: CodePurpose.recovery,
          resendAfter: const Duration(seconds: 1),
          onVerified: () => verified++,
        ),
        overrides: _auth(repo),
      ),
    );
    await _wait(tester, 1500);
    await tester.tap(find.text('Renvoyer le code'));
    await _wait(tester, 200);
    expect(repo.codesSent, [(_email, CodePurpose.recovery)]);
    await _type(tester, '123456');
    await _wait(tester, 200);
    expect(verified, 1);
  });

  testWidgets('the right code signs in', (tester) async {
    var verified = 0;
    final repo = FakeAuthRepository();
    await tester.pumpWidget(
      harness(
        CodeScreen(email: _email, onVerified: () => verified++),
        overrides: _auth(repo),
      ),
    );
    await _type(tester, '123456'); // auto-submits at 6 digits
    await _wait(tester);
    expect(verified, 1);
    expect(repo.currentUser?.email, _email);
  });

  testWidgets('wrong codes count down the tries, then lock until resend', (
    tester,
  ) async {
    final repo = FakeAuthRepository(delay: Duration.zero);
    await tester.pumpWidget(
      harness(
        const CodeScreen(email: _email, resendAfter: Duration(seconds: 2)),
        overrides: _auth(repo),
      ),
    );
    await _type(tester, '000000');
    await _wait(tester, 200);
    expect(find.text('Code incorrect, il te reste 2 essais.'), findsOneWidget);
    await _type(tester, '000000');
    await _wait(tester, 200);
    expect(find.text('Code incorrect, il te reste 1 essai.'), findsOneWidget);
    await _type(tester, '000000');
    await _wait(tester, 200);
    expect(
      find.text('Trop d’essais. Demande un nouveau code.'),
      findsOneWidget,
    );

    // After the countdown, resend unlocks the screen.
    await _wait(tester, 2500);
    await tester.tap(find.text('Renvoyer le code'));
    await _wait(tester, 300);
    expect(repo.codesSent, [(_email, CodePurpose.signUp)]);
    expect(find.textContaining('Trop d’essais'), findsNothing);
    expect(find.textContaining('Renvoyer le code dans'), findsOneWidget);
  });

  testWidgets('an expired code asks for a new one', (tester) async {
    await tester.pumpWidget(
      harness(
        const CodeScreen(email: _email),
        overrides: _auth(
          FakeAuthRepository(expired: true, delay: Duration.zero),
        ),
      ),
    );
    await _type(tester, '123456');
    await _wait(tester, 200);
    expect(find.text('Code expiré, demande un nouveau code.'), findsOneWidget);
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
  });

  testWidgets('no network: banner', (tester) async {
    await tester.pumpWidget(
      harness(
        const CodeScreen(email: _email),
        overrides: _auth(
          FakeAuthRepository(offline: true, delay: Duration.zero),
        ),
      ),
    );
    await _type(tester, '123456');
    await _wait(tester, 200);
    expect(
      find.text('Pas de connexion. Réessaie dans un instant.'),
      findsOneWidget,
    );
    await _wait(tester, 5000);
  });

  testWidgets('"Changer d’adresse" goes back to the form', (tester) async {
    var back = 0;
    await tester.pumpWidget(
      harness(CodeScreen(email: _email, onChangeEmail: () => back++)),
    );
    expect(find.textContaining(_email), findsOneWidget);
    await tester.tapOnText(find.textRange.ofSubstring('Changer d’adresse'));
    expect(back, 1);
  });

  testWidgets('the countdown reaches zero and offers to resend', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const CodeScreen(email: _email, resendAfter: Duration(seconds: 3)),
      ),
    );
    expect(find.text('Renvoyer le code dans 0:03'), findsOneWidget);
    await _wait(tester, 1000);
    expect(find.text('Renvoyer le code dans 0:02'), findsOneWidget);
    await _wait(tester, 2500);
    expect(find.text('Renvoyer le code'), findsOneWidget);
  });
}

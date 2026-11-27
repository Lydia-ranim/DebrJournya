import 'package:debrjournya/core/widgets/app_button.dart';
import 'package:debrjournya/core/widgets/password_field.dart';
import 'package:debrjournya/features/auth/data/auth_repository.dart';
import 'package:debrjournya/features/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Future<void> _wait(WidgetTester tester, [int ms = 1000]) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder get _emailField => find.byType(TextField).at(0);
Finder get _passwordField => find.descendant(
  of: find.byType(PasswordField),
  matching: find.byType(TextField),
);

AppButton _button(WidgetTester tester) =>
    tester.widget<AppButton>(find.byType(AppButton));

void main() {
  setUpAll(loadAppFonts);
  setUp(resetPrefs);

  screenGoldens('auth_sign_up', () => const SignUpScreen(), height: 1060);
  robustnessTests('Inscription', () => const SignUpScreen());

  Future<void> fill(WidgetTester tester, String email, String password) async {
    await tester.enterText(_emailField, email);
    await tester.enterText(_passwordField, password);
    await tester.ensureVisible(find.textContaining('J’accepte'));
    await tester.tapOnText(find.textRange.ofSubstring('J’accepte les'));
    await tester.pump();
  }

  testWidgets('creating an account sends a code', (tester) async {
    final repo = FakeAuthRepository(delay: Duration.zero);
    String? sent;
    await tester.pumpWidget(
      harness(
        SignUpScreen(onCodeSent: (e) => sent = e),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    expect(_button(tester).onPressed, isNull);
    await fill(tester, 'amina@exemple.com', 'motdepasse');
    expect(_button(tester).onPressed, isNotNull);
    await tester.tap(find.byType(AppButton));
    await _wait(tester, 300);
    expect(sent, 'amina@exemple.com');
    expect(repo.codesSent, [('amina@exemple.com', CodePurpose.signUp)]);
  });

  testWidgets('short password and taken e-mail are explained', (tester) async {
    final repo = FakeAuthRepository(
      delay: Duration.zero,
      accounts: {'amina@exemple.com': 'motdepasse'},
    );
    await tester.pumpWidget(
      harness(
        const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await fill(tester, 'amina@exemple.com', '123');
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(find.text('8 caractères minimum.'), findsOneWidget);

    await tester.enterText(_passwordField, 'motdepasse');
    await tester.tap(find.byType(AppButton));
    await _wait(tester, 300);
    expect(
      find.text('Un compte existe déjà avec cette adresse. Connecte-toi.'),
      findsOneWidget,
    );
  });

  testWidgets('social sign-up needs the consent box', (tester) async {
    final repo = FakeAuthRepository(delay: Duration.zero);
    await tester.pumpWidget(
      harness(
        const SignUpScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.ensureVisible(find.text('Continuer avec Google'));
    await tester.tap(find.text('Continuer avec Google'));
    await _wait(tester, 200);
    expect(repo.socialOpened, isEmpty);

    await tester.ensureVisible(find.textContaining('J’accepte'));
    await tester.tapOnText(find.textRange.ofSubstring('J’accepte les'));
    await tester.pump();
    await tester.ensureVisible(find.text('Continuer avec Google'));
    await tester.tap(find.text('Continuer avec Google'));
    await _wait(tester, 200);
    expect(repo.socialOpened, [SocialProvider.google]);
  });
}

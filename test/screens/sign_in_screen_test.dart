import 'package:debrjournya/core/widgets/app_button.dart';
import 'package:debrjournya/core/widgets/password_field.dart';
import 'package:debrjournya/features/auth/data/auth_repository.dart';
import 'package:debrjournya/features/auth/sign_in_screen.dart';
import 'package:debrjournya/features/auth/widgets/social_buttons.dart';
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

void main() {
  setUpAll(loadAppFonts);
  setUp(resetPrefs);

  screenGoldens('auth_sign_in', () => const SignInScreen(), height: 1000);
  robustnessTests('Connexion', () => const SignInScreen());

  FakeAuthRepository repo0() => FakeAuthRepository(
    delay: Duration.zero,
    accounts: {'amina@exemple.com': 'motdepasse'},
  );

  testWidgets('right e-mail and password sign in', (tester) async {
    final repo = repo0();
    await tester.pumpWidget(
      harness(
        const SignInScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.enterText(_emailField, ' Amina@Exemple.com ');
    await tester.enterText(_passwordField, 'motdepasse');
    await tester.tap(find.byType(AppButton));
    await _wait(tester, 300);
    expect(repo.currentUser?.email, 'amina@exemple.com');
  });

  testWidgets('wrong password and bad e-mail show field errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        const SignInScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo0())],
      ),
    );
    await tester.enterText(_emailField, 'amina');
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(find.text('Adresse e-mail invalide.'), findsOneWidget);

    await tester.enterText(_emailField, 'amina@exemple.com');
    await tester.enterText(_passwordField, 'faux-mot');
    await tester.tap(find.byType(AppButton));
    await _wait(tester, 300);
    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('an unconfirmed account gets a new code', (tester) async {
    final repo = FakeAuthRepository(delay: Duration.zero);
    // Real async: the fake's delay would never fire inside the test clock.
    await tester.runAsync(() => repo.signUp('new@exemple.com', 'motdepasse'));
    repo.codesSent.clear();
    String? needsCode;
    await tester.pumpWidget(
      harness(
        SignInScreen(onNeedsCode: (e) => needsCode = e),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.enterText(_emailField, 'new@exemple.com');
    await tester.enterText(_passwordField, 'motdepasse');
    await tester.tap(find.byType(AppButton));
    await _wait(tester, 300);
    expect(needsCode, 'new@exemple.com');
    expect(repo.codesSent.last, ('new@exemple.com', CodePurpose.signUp));
  });

  testWidgets('Google opens its sign-in; Facebook is hidden for now', (
    tester,
  ) async {
    final repo = repo0();
    await tester.pumpWidget(
      harness(
        const SignInScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    expect(find.text('Continuer avec Facebook'), findsNothing);
    await tester.ensureVisible(find.text('Continuer avec Google'));
    await tester.tap(find.text('Continuer avec Google'));
    await _wait(tester, 200);
    expect(repo.socialOpened, [SocialProvider.google]);
  });

  testWidgets('the Facebook button works when switched on', (tester) async {
    final opened = <SocialProvider>[];
    await tester.pumpWidget(
      harness(
        Scaffold(
          body: SocialButtons(onPressed: opened.add, showFacebook: true),
        ),
      ),
    );
    await tester.tap(find.text('Continuer avec Facebook'));
    expect(opened, [SocialProvider.facebook]);
  });

  testWidgets('links go to sign-up and password recovery', (tester) async {
    var create = 0;
    String? forgot;
    await tester.pumpWidget(
      harness(
        SignInScreen(
          onCreateAccount: () => create++,
          onForgotPassword: (e) => forgot = e,
        ),
      ),
    );
    await tester.enterText(_emailField, 'amina@exemple.com');
    await tester.tap(find.text('Mot de passe oublié ?'));
    expect(forgot, 'amina@exemple.com');
    await tester.ensureVisible(find.textContaining('Pas encore de compte'));
    await tester.tapOnText(find.textRange.ofSubstring('Créer un compte'));
    expect(create, 1);
  });

  testWidgets('the password can be shown', (tester) async {
    await tester.pumpWidget(harness(const SignInScreen()));
    bool hidden() => tester.widget<TextField>(_passwordField).obscureText;
    expect(hidden(), isTrue);
    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(hidden(), isFalse);
  });
}

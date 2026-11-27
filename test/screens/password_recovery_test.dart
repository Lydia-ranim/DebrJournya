import 'package:debrjournya/core/widgets/app_button.dart';
import 'package:debrjournya/features/auth/data/auth_repository.dart';
import 'package:debrjournya/features/auth/forgot_password_screen.dart';
import 'package:debrjournya/features/auth/new_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Future<void> _wait(WidgetTester tester, [int ms = 1000]) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(loadAppFonts);
  setUp(resetPrefs);

  screenGoldens(
    'auth_forgot',
    () => const ForgotPasswordScreen(initialEmail: 'amina@exemple.com'),
  );
  screenGoldens('auth_new_password', () => const NewPasswordScreen());
  robustnessTests('Mot de passe oublié', () => const ForgotPasswordScreen());
  robustnessTests('Nouveau mot de passe', () => const NewPasswordScreen());

  testWidgets('forgot password e-mails a recovery code', (tester) async {
    final repo = FakeAuthRepository(delay: Duration.zero);
    String? sent;
    await tester.pumpWidget(
      harness(
        ForgotPasswordScreen(
          initialEmail: 'Amina@Exemple.com',
          onCodeSent: (e) => sent = e,
        ),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.tap(find.byType(AppButton));
    await _wait(tester, 300);
    expect(sent, 'amina@exemple.com');
    expect(repo.codesSent, [('amina@exemple.com', CodePurpose.recovery)]);
  });

  testWidgets('the new password must be long enough', (tester) async {
    final repo = FakeAuthRepository(delay: Duration.zero);
    var done = 0;
    await tester.pumpWidget(
      harness(
        NewPasswordScreen(onDone: () => done++),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      ),
    );
    await tester.enterText(find.byType(TextField), 'court');
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(find.text('8 caractères minimum.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'nouveau-mot');
    await tester.tap(find.byType(AppButton));
    await _wait(tester, 300);
    expect(done, 1);
  });
}

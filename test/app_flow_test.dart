// The real app (router, storage, locale) driven end to end, on the fake
// auth and profile repositories.
import 'package:debrjournya/app.dart';
import 'package:debrjournya/core/router/app_router.dart';
import 'package:debrjournya/core/storage/preferences.dart';
import 'package:debrjournya/core/widgets/app_button.dart';
import 'package:debrjournya/core/widgets/coming_soon_screen.dart';
import 'package:debrjournya/core/widgets/password_field.dart';
import 'package:debrjournya/features/auth/code_screen.dart';
import 'package:debrjournya/features/auth/data/auth_repository.dart';
import 'package:debrjournya/features/auth/data/profile_repository.dart';
import 'package:debrjournya/features/auth/new_password_screen.dart';
import 'package:debrjournya/features/auth/sign_in_screen.dart';
import 'package:debrjournya/features/auth/sign_up_screen.dart';
import 'package:debrjournya/features/language/language_screen.dart';
import 'package:debrjournya/features/onboarding/onboarding_screen.dart';
import 'package:debrjournya/features/role/role_screen.dart';
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

Widget _app({AuthRepository? auth, ProfileRepository? profiles}) =>
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(testPrefs!),
        authRepositoryProvider.overrideWithValue(
          auth ?? FakeAuthRepository(delay: Duration.zero),
        ),
        profileRepositoryProvider.overrideWithValue(
          profiles ?? FakeProfileRepository(),
        ),
      ],
      child: const DebrJournyaApp(),
    );

Future<void> _passSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await _settle(tester);
}

Finder get _email => find.byType(TextField).first;
Finder get _password => find.descendant(
  of: find.byType(PasswordField),
  matching: find.byType(TextField),
);

String _route(WidgetTester tester) =>
    tester.widget<ComingSoonScreen>(find.byType(ComingSoonScreen)).routeName;

void main() {
  testWidgets(
    'first launch in Arabic: language → onboarding → sign-up → code → role '
    '→ home → sign-out → sign-in',
    (tester) async {
      await resetPrefs();
      await tester.pumpWidget(_app());
      expect(find.byType(SplashScreen), findsOneWidget);

      await _passSplash(tester);
      await tester.tap(find.text('العربية'));
      await _settle(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(OnboardingScreen))),
        TextDirection.rtl,
      );
      await tester.tap(find.text('تخطٍّ'));
      await _settle(tester);
      expect(find.byType(SignInScreen), findsOneWidget);

      // Sign-in → "create an account".
      await tester.ensureVisible(find.textContaining('ليس لديك حساب'));
      await tester.tapOnText(find.textRange.ofSubstring('أنشئ حسابًا'));
      await _settle(tester);
      expect(find.byType(SignUpScreen), findsOneWidget);

      await tester.enterText(_email, 'amina@exemple.com');
      await tester.enterText(_password, 'motdepasse');
      await tester.ensureVisible(find.textContaining('أوافق'));
      await tester.tapOnText(find.textRange.ofSubstring('أوافق'));
      await tester.pump();
      await tester.ensureVisible(find.byType(AppButton));
      await tester.tap(find.byType(AppButton));
      await _settle(tester);
      expect(find.byType(CodeScreen), findsOneWidget);

      // The e-mailed code (fake: 123456) confirms the account → A6.
      await tester.enterText(find.byType(TextField), '123456');
      await _settle(tester);
      expect(find.byType(RoleScreen), findsOneWidget);

      await tester.tap(find.text('أبحث عن عمل'));
      await _settle(tester);
      expect(_route(tester), Routes.studentHome);
      expect(testPrefs!.getString(PrefKeys.role), 'student');

      await tester.tap(find.text('تسجيل الخروج'));
      await _settle(tester);
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(testPrefs!.getString(PrefKeys.role), isNull);

      // Signing in again: the role comes back from the profile.
      await tester.enterText(_email, 'amina@exemple.com');
      await tester.enterText(_password, 'motdepasse');
      await tester.tap(find.byType(AppButton));
      await _settle(tester);
      expect(_route(tester), Routes.studentHome);
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

  testWidgets('signed-out returning user lands on sign-in', (tester) async {
    await resetPrefs({
      PrefKeys.languageCode: 'fr',
      PrefKeys.onboardingSeen: true,
    });
    await tester.pumpWidget(_app());
    await _passSplash(tester);
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('signed-in user with a cached role opens on their home', (
    tester,
  ) async {
    await resetPrefs({
      PrefKeys.languageCode: 'fr',
      PrefKeys.onboardingSeen: true,
      PrefKeys.role: 'employer',
    });
    await tester.pumpWidget(
      _app(
        auth: FakeAuthRepository(
          signedIn: const AuthUser(id: 'u1', email: 'cafe@exemple.com'),
        ),
      ),
    );
    await _passSplash(tester);
    expect(_route(tester), Routes.employerHome);
  });

  testWidgets('forgot password: code → new password → home', (tester) async {
    await resetPrefs({
      PrefKeys.languageCode: 'fr',
      PrefKeys.onboardingSeen: true,
    });
    final auth = FakeAuthRepository(
      delay: Duration.zero,
      accounts: {'amina@exemple.com': 'ancien-mot'},
    );
    await tester.pumpWidget(
      _app(
        auth: auth,
        profiles: FakeProfileRepository(role: UserRole.student),
      ),
    );
    await _passSplash(tester);
    await tester.enterText(_email, 'amina@exemple.com');
    await tester.tap(find.text('Mot de passe oublié ?'));
    await _settle(tester);
    await tester.tap(find.byType(AppButton));
    await _settle(tester);
    expect(find.byType(CodeScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await _settle(tester);
    expect(find.byType(NewPasswordScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'nouveau-mot');
    await tester.tap(find.byType(AppButton));
    await _settle(tester);
    expect(_route(tester), Routes.studentHome);
  });
}

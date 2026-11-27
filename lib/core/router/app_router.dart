import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/code_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/profile_repository.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/new_password_screen.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/language/language_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/role/role_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../l10n/locale_provider.dart';
import '../storage/preferences.dart';
import '../widgets/coming_soon_screen.dart';

/// Every route path, in one place. Screens navigate with `context.go(Routes.x)`.
abstract final class Routes {
  static const splash = '/';
  static const language = '/language';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';

  /// Code screen; `extra` is a [VerifyArgs].
  static const verify = '/verify';
  static const forgot = '/forgot';
  static const newPassword = '/new-password';
  static const role = '/role';
  static const studentHome = '/student';
  static const employerHome = '/employer';
  static const terms = '/terms';
  static const privacy = '/privacy';

  /// Routes that need a signed-in user.
  static const signedIn = {role, studentHome, employerHome, newPassword};

  /// Screens from which a finished sign-in (password, Google, Facebook)
  /// moves on by itself.
  static const signingIn = {signIn, signUp, forgot};

  static String home(UserRole role) =>
      role == UserRole.student ? studentHome : employerHome;
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  UserRole? cachedRole() {
    final name = prefs.getString(PrefKeys.role);
    return name == null ? null : UserRole.values.byName(name);
  }

  /// Where a signed-in user belongs: their home, or A6 if no role yet.
  /// Uses the role cached on the device first, so the app opens offline.
  Future<String> signedInDestination() async {
    final cached = cachedRole();
    if (cached != null) return Routes.home(cached);
    try {
      final role = await ref.read(profileRepositoryProvider).myRole();
      if (role == null) return Routes.role;
      await prefs.setString(PrefKeys.role, role.name);
      return Routes.home(role);
    } catch (_) {
      return Routes.role;
    }
  }

  Future<void> signOut(GoRouter router) async {
    await prefs.remove(PrefKeys.role);
    await auth.signOut();
    router.go(Routes.signIn);
  }

  final refresh = _StreamListenable(auth.changes);
  ref.onDispose(refresh.dispose);

  late final GoRouter router;
  router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    // Signed out (or session expired) on a signed-in screen → A4.
    redirect: (context, state) {
      if (auth.currentUser == null &&
          Routes.signedIn.contains(state.matchedLocation)) {
        return Routes.signIn;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => SplashScreen(
          onReady: () async {
            final seen = prefs.getBool(PrefKeys.onboardingSeen) ?? false;
            if (ref.read(localeProvider) == null) {
              router.go(Routes.language);
            } else if (auth.currentUser != null) {
              router.go(await signedInDestination());
            } else {
              router.go(seen ? Routes.signIn : Routes.onboarding);
            }
          },
        ),
      ),
      GoRoute(
        path: Routes.language,
        builder: (context, state) =>
            LanguageScreen(onChosen: () => router.go(Routes.onboarding)),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) =>
            OnboardingScreen(onDone: () => router.go(Routes.signIn)),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) => SignInScreen(
          onCreateAccount: () => router.push(Routes.signUp),
          onForgotPassword: (email) => router.push(Routes.forgot, extra: email),
          onNeedsCode: (email) => router.push(
            Routes.verify,
            extra: VerifyArgs(email, CodePurpose.signUp),
          ),
        ),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => SignUpScreen(
          onBack: () => router.pop(),
          onSignIn: () => router.go(Routes.signIn),
          onCodeSent: (email) => router.push(
            Routes.verify,
            extra: VerifyArgs(email, CodePurpose.signUp),
          ),
          onOpenTerms: () => router.push(Routes.terms),
          onOpenPrivacy: () => router.push(Routes.privacy),
        ),
      ),
      GoRoute(
        path: Routes.verify,
        redirect: (context, state) =>
            state.extra is VerifyArgs ? null : Routes.signIn,
        builder: (context, state) {
          final args = state.extra! as VerifyArgs;
          return CodeScreen(
            email: args.email,
            purpose: args.purpose,
            onChangeEmail: () => router.pop(),
            // A recovery sign-in opens the new-password screen through the
            // passwordRecovery stream; a sign-up moves on here.
            onVerified: args.purpose == CodePurpose.recovery
                ? null
                : () async => router.go(await signedInDestination()),
          );
        },
      ),
      GoRoute(
        path: Routes.forgot,
        builder: (context, state) => ForgotPasswordScreen(
          initialEmail: state.extra is String ? state.extra! as String : '',
          onBack: () => router.pop(),
          onCodeSent: (email) => router.push(
            Routes.verify,
            extra: VerifyArgs(email, CodePurpose.recovery),
          ),
        ),
      ),
      GoRoute(
        path: Routes.newPassword,
        builder: (context, state) => NewPasswordScreen(
          onDone: () async => router.go(await signedInDestination()),
        ),
      ),
      GoRoute(
        path: Routes.role,
        builder: (context, state) =>
            RoleScreen(onChosen: (role) => router.go(Routes.home(role))),
      ),
      // Not built yet: the two homes (B4 / C4) and the legal pages (D5).
      for (final path in [Routes.studentHome, Routes.employerHome])
        GoRoute(
          path: path,
          builder: (context, state) => ComingSoonScreen(
            routeName: path,
            onSignOut: () => signOut(router),
          ),
        ),
      for (final path in [Routes.terms, Routes.privacy])
        GoRoute(
          path: path,
          builder: (context, state) => ComingSoonScreen(routeName: path),
        ),
    ],
  );
  // A sign-in finishing on a sign-in screen (password, or Google/Facebook
  // coming back from the browser) opens A6 or the user's home. The code
  // screen navigates itself (a recovery code must lead to a new password).
  // Also on the sign-up code screen: the e-mail may hold a confirmation
  // link instead of a code, and opening it signs the user in.
  final signedInSub = auth.changes.listen((user) async {
    final here = router.state.matchedLocation;
    final extra = router.state.extra;
    final waitingForSignUp =
        here == Routes.verify &&
        extra is VerifyArgs &&
        extra.purpose == CodePurpose.signUp;
    if (user != null && (Routes.signingIn.contains(here) || waitingForSignUp)) {
      router.go(await signedInDestination());
    }
  });
  ref.onDispose(signedInSub.cancel);

  // Recovery code checked or reset link opened → choose a new password.
  final recoverySub = auth.passwordRecovery.listen(
    (_) => router.go(Routes.newPassword),
  );
  ref.onDispose(recoverySub.cancel);

  ref.onDispose(router.dispose);
  return router;
});

/// Lets go_router re-check its redirect whenever the auth state changes.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// What the code screen needs: the address and why the code was sent.
class VerifyArgs {
  const VerifyArgs(this.email, this.purpose);

  final String email;
  final CodePurpose purpose;
}

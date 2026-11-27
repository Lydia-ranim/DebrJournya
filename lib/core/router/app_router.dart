import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/language/language_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../l10n/locale_provider.dart';
import '../storage/preferences.dart';
import '../widgets/coming_soon_screen.dart';

/// Every route path, in one place. Screens navigate with `context.go(Routes.x)`.
abstract final class Routes {
  static const splash = '/';
  static const language = '/language';
  static const onboarding = '/onboarding';
  static const phone = '/phone';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => SplashScreen(
          onReady: () {
            final prefs = ref.read(sharedPreferencesProvider);
            final seen = prefs.getBool(PrefKeys.onboardingSeen) ?? false;
            if (ref.read(localeProvider) == null) {
              context.go(Routes.language);
            } else {
              context.go(seen ? Routes.phone : Routes.onboarding);
            }
          },
        ),
      ),
      GoRoute(
        path: Routes.language,
        builder: (context, state) =>
            LanguageScreen(onChosen: () => context.go(Routes.onboarding)),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) =>
            OnboardingScreen(onDone: () => context.go(Routes.phone)),
      ),
      GoRoute(
        path: Routes.phone,
        builder: (context, state) =>
            const ComingSoonScreen(routeName: Routes.phone),
      ),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

class DebrJournyaApp extends StatelessWidget {
  const DebrJournyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DebrJournya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Arabic if the phone is in Arabic, French otherwise. The user's own
      // choice (A3 · Langue) will override this once that screen exists.
      localeResolutionCallback: resolveLocale,
      // TODO(A3): navigate to the language screen in onReady.
      home: const SplashScreen(),
    );
  }
}

Locale resolveLocale(Locale? device, Iterable<Locale> supported) {
  if (device?.languageCode == 'ar') return const Locale('ar');
  return const Locale('fr');
}

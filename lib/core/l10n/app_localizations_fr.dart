// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'DebrJournya';

  @override
  String get splashTagline => 'Le job qui s’adapte à ton emploi du temps';

  @override
  String get mascotLabel => 'Jobby, la mascotte';

  @override
  String get loadingLabel => 'Chargement';

  @override
  String get commonComingSoon => 'Bientôt disponible';

  @override
  String get languageTitle => 'Choisis ta langue';

  @override
  String get languageLead =>
      'Tu pourras la changer à tout moment dans les réglages.';

  @override
  String get languageTileLabel => 'FR';

  @override
  String get languageName => 'Français';

  @override
  String get languageDescription => 'Toute l’application en français.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboarding1Title => 'Trouve un job flexible';

  @override
  String get onboarding1Lead =>
      'Missions, jobs et événements près de chez toi, qui respectent tes cours.';

  @override
  String get onboarding2Title => 'Remplis tes créneaux, vite';

  @override
  String get onboarding2Lead =>
      'Indique tes disponibilités une fois. On te propose ce qui colle.';

  @override
  String get onboarding3Title => 'Construis ton CV';

  @override
  String get onboarding3Lead =>
      'Chaque mission terminée s’ajoute à ton CV, prêt à envoyer.';

  @override
  String onboardingProgress(int current, int total) {
    return 'Page $current sur $total';
  }
}

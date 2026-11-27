import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// Brand name. Never translated; always written in Latin letters.
  ///
  /// In fr, this message translates to:
  /// **'DebrJournya'**
  String get appName;

  /// Brand tagline under the wordmark on the splash screen (A1).
  ///
  /// In fr, this message translates to:
  /// **'Le job qui s’adapte à ton emploi du temps'**
  String get splashTagline;

  /// Screen-reader label for the animated briefcase mascot.
  ///
  /// In fr, this message translates to:
  /// **'Jobby, la mascotte'**
  String get mascotLabel;

  /// Screen-reader label for the three animated loading dots.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get loadingLabel;

  /// Placeholder for a screen that is not built yet.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get commonComingSoon;

  /// A3 title. Shown in BOTH languages at once (each line read from its own locale).
  ///
  /// In fr, this message translates to:
  /// **'Choisis ta langue'**
  String get languageTitle;

  /// A3 intro under the titles, in the current app language.
  ///
  /// In fr, this message translates to:
  /// **'Tu pourras la changer à tout moment dans les réglages.'**
  String get languageLead;

  /// A3 card tile: short mark of this language (Latin 'FR', Arabic letter 'ع').
  ///
  /// In fr, this message translates to:
  /// **'FR'**
  String get languageTileLabel;

  /// A3 card title: this language's own name.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageName;

  /// A3 card text, written in this language.
  ///
  /// In fr, this message translates to:
  /// **'Toute l’application en français.'**
  String get languageDescription;

  /// A2 header action: skip the slides.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// A2 button on slides 1–2.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// A2 button on the last slide.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// A2 slide 1 title.
  ///
  /// In fr, this message translates to:
  /// **'Trouve un job flexible'**
  String get onboarding1Title;

  /// A2 slide 1 text.
  ///
  /// In fr, this message translates to:
  /// **'Missions, jobs et événements près de chez toi, qui respectent tes cours.'**
  String get onboarding1Lead;

  /// A2 slide 2 title.
  ///
  /// In fr, this message translates to:
  /// **'Remplis tes créneaux, vite'**
  String get onboarding2Title;

  /// A2 slide 2 text.
  ///
  /// In fr, this message translates to:
  /// **'Indique tes disponibilités une fois. On te propose ce qui colle.'**
  String get onboarding2Lead;

  /// A2 slide 3 title.
  ///
  /// In fr, this message translates to:
  /// **'Construis ton CV'**
  String get onboarding3Title;

  /// A2 slide 3 text.
  ///
  /// In fr, this message translates to:
  /// **'Chaque mission terminée s’ajoute à ton CV, prêt à envoyer.'**
  String get onboarding3Lead;

  /// Screen-reader label of the A2 page dots.
  ///
  /// In fr, this message translates to:
  /// **'Page {current} sur {total}'**
  String onboardingProgress(int current, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

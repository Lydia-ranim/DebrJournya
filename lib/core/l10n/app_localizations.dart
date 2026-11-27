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

  /// Back button (screen readers, tooltip).
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// Banner shown when the device is offline.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Réessaie dans un instant.'**
  String get commonNoConnection;

  /// Sign-out action.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get commonSignOut;

  /// Shown when the server rate-limits SMS codes.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes. Réessaie dans quelques minutes.'**
  String get commonTooManyRequests;

  /// A5 title.
  ///
  /// In fr, this message translates to:
  /// **'Entre le code'**
  String get codeTitle;

  /// Screen-reader label of the A5 code boxes.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get codeFieldLabel;

  /// A5 countdown before resending; time like 0:42.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code dans {time}'**
  String codeResendIn(String time);

  /// A5 action once the countdown is over.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get codeResend;

  /// A5 main button.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get codeVerify;

  /// A5 error after a wrong code; count = tries left.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Code incorrect, il te reste 1 essai.} other{Code incorrect, il te reste {count} essais.}}'**
  String codeWrong(int count);

  /// A5 error after the last wrong try.
  ///
  /// In fr, this message translates to:
  /// **'Trop d’essais. Demande un nouveau code.'**
  String get codeNoTriesLeft;

  /// A5 error when the code is too old.
  ///
  /// In fr, this message translates to:
  /// **'Code expiré, demande un nouveau code.'**
  String get codeExpired;

  /// A6 title, first line.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue !'**
  String get roleTitle1;

  /// A6 title, second line.
  ///
  /// In fr, this message translates to:
  /// **'Que viens-tu faire ici ?'**
  String get roleTitle2;

  /// A6 text under the title.
  ///
  /// In fr, this message translates to:
  /// **'Tu pourras ajouter l’autre rôle plus tard.'**
  String get roleLead;

  /// A6 student card title.
  ///
  /// In fr, this message translates to:
  /// **'Je cherche du travail'**
  String get roleStudentTitle;

  /// A6 student card text.
  ///
  /// In fr, this message translates to:
  /// **'Jobs, missions et bénévolat qui respectent ton emploi du temps.'**
  String get roleStudentText;

  /// A6 employer card title.
  ///
  /// In fr, this message translates to:
  /// **'Je recrute'**
  String get roleEmployerTitle;

  /// A6 employer card text.
  ///
  /// In fr, this message translates to:
  /// **'Publie une annonce et trouve des étudiants disponibles en quelques minutes.'**
  String get roleEmployerText;

  /// Shown when the server fails for an unexpected reason.
  ///
  /// In fr, this message translates to:
  /// **'Un problème est survenu. Réessaie dans un instant.'**
  String get commonUnexpectedError;

  /// E-mail field label.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get authEmailLabel;

  /// E-mail field placeholder.
  ///
  /// In fr, this message translates to:
  /// **'toi@exemple.com'**
  String get authEmailHint;

  /// Password field label.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPasswordLabel;

  /// Hint under a new password.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum.'**
  String get authPasswordHelper;

  /// Eye button (screen readers).
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get authShowPassword;

  /// Eye button (screen readers).
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get authHidePassword;

  /// Divider between e-mail sign-in and social buttons.
  ///
  /// In fr, this message translates to:
  /// **'ou'**
  String get authOr;

  /// Google sign-in button.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get authWithGoogle;

  /// Facebook sign-in button.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Facebook'**
  String get authWithFacebook;

  /// E-mail field error.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get authInvalidEmail;

  /// Password field error.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum.'**
  String get authPasswordTooShort;

  /// Sign-in error.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get authWrongCredentials;

  /// Sign-up error.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cette adresse. Connecte-toi.'**
  String get authEmailTaken;

  /// Sign-in title.
  ///
  /// In fr, this message translates to:
  /// **'Content de te revoir'**
  String get signInTitle;

  /// Sign-in text under the title.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi pour retrouver tes offres et tes candidatures.'**
  String get signInLead;

  /// Sign-in link to password recovery.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get signInForgot;

  /// Sign-in main button.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signInButton;

  /// Sign-in footer; contains signInCreateLink word for word.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? Créer un compte'**
  String get signInNoAccount;

  /// Link inside signInNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get signInCreateLink;

  /// Sign-up title.
  ///
  /// In fr, this message translates to:
  /// **'Crée ton compte'**
  String get signUpTitle;

  /// Sign-up text under the title.
  ///
  /// In fr, this message translates to:
  /// **'Un e-mail et un mot de passe suffisent. On t’envoie un code pour vérifier ton adresse.'**
  String get signUpLead;

  /// Sign-up main button.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get signUpButton;

  /// Sign-up footer; contains signUpSignInLink word for word.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get signUpHaveAccount;

  /// Link inside signUpHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signUpSignInLink;

  /// Code screen line; email address.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé à {email}.'**
  String codeSentToEmail(String email);

  /// Code screen link back to the e-mail form.
  ///
  /// In fr, this message translates to:
  /// **'Changer d’adresse'**
  String get codeChangeEmail;

  /// Password recovery title.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotTitle;

  /// Password recovery text.
  ///
  /// In fr, this message translates to:
  /// **'Entre ton e-mail : on t’envoie un code pour choisir un nouveau mot de passe.'**
  String get forgotLead;

  /// Password recovery button.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get forgotButton;

  /// New password title.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordTitle;

  /// New password text.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un mot de passe que tu n’utilises pas ailleurs.'**
  String get newPasswordLead;

  /// New password button.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get newPasswordButton;

  /// Sign-up consent checkbox text; contains authTerms and authPrivacy word for word.
  ///
  /// In fr, this message translates to:
  /// **'J’accepte les conditions d’utilisation et la politique de confidentialité.'**
  String get authConsent;

  /// Consent link (must appear inside authConsent).
  ///
  /// In fr, this message translates to:
  /// **'conditions d’utilisation'**
  String get authTerms;

  /// Consent link (must appear inside authConsent).
  ///
  /// In fr, this message translates to:
  /// **'politique de confidentialité'**
  String get authPrivacy;

  /// Code screen hint: the e-mail may contain a link instead of a code.
  ///
  /// In fr, this message translates to:
  /// **'Tu as reçu un lien plutôt qu’un code ? Ouvre-le sur ce téléphone.'**
  String get codeLinkHint;
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

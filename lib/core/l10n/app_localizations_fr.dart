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

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNoConnection =>
      'Pas de connexion. Réessaie dans un instant.';

  @override
  String get commonSignOut => 'Se déconnecter';

  @override
  String get commonTooManyRequests =>
      'Trop de demandes. Réessaie dans quelques minutes.';

  @override
  String get codeTitle => 'Entre le code';

  @override
  String get codeFieldLabel => 'Code à 6 chiffres';

  @override
  String codeResendIn(String time) {
    return 'Renvoyer le code dans $time';
  }

  @override
  String get codeResend => 'Renvoyer le code';

  @override
  String get codeVerify => 'Vérifier';

  @override
  String codeWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Code incorrect, il te reste $count essais.',
      one: 'Code incorrect, il te reste 1 essai.',
    );
    return '$_temp0';
  }

  @override
  String get codeNoTriesLeft => 'Trop d’essais. Demande un nouveau code.';

  @override
  String get codeExpired => 'Code expiré, demande un nouveau code.';

  @override
  String get roleTitle1 => 'Bienvenue !';

  @override
  String get roleTitle2 => 'Que viens-tu faire ici ?';

  @override
  String get roleLead => 'Tu pourras ajouter l’autre rôle plus tard.';

  @override
  String get roleStudentTitle => 'Je cherche du travail';

  @override
  String get roleStudentText =>
      'Jobs, missions et bénévolat qui respectent ton emploi du temps.';

  @override
  String get roleEmployerTitle => 'Je recrute';

  @override
  String get roleEmployerText =>
      'Publie une annonce et trouve des étudiants disponibles en quelques minutes.';

  @override
  String get commonUnexpectedError =>
      'Un problème est survenu. Réessaie dans un instant.';

  @override
  String get authEmailLabel => 'Adresse e-mail';

  @override
  String get authEmailHint => 'toi@exemple.com';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHelper => '8 caractères minimum.';

  @override
  String get authShowPassword => 'Afficher le mot de passe';

  @override
  String get authHidePassword => 'Masquer le mot de passe';

  @override
  String get authOr => 'ou';

  @override
  String get authWithGoogle => 'Continuer avec Google';

  @override
  String get authWithFacebook => 'Continuer avec Facebook';

  @override
  String get authInvalidEmail => 'Adresse e-mail invalide.';

  @override
  String get authPasswordTooShort => '8 caractères minimum.';

  @override
  String get authWrongCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get authEmailTaken =>
      'Un compte existe déjà avec cette adresse. Connecte-toi.';

  @override
  String get signInTitle => 'Content de te revoir';

  @override
  String get signInLead =>
      'Connecte-toi pour retrouver tes offres et tes candidatures.';

  @override
  String get signInForgot => 'Mot de passe oublié ?';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get signInNoAccount => 'Pas encore de compte ? Créer un compte';

  @override
  String get signInCreateLink => 'Créer un compte';

  @override
  String get signUpTitle => 'Crée ton compte';

  @override
  String get signUpLead =>
      'Un e-mail et un mot de passe suffisent. On t’envoie un code pour vérifier ton adresse.';

  @override
  String get signUpButton => 'Créer mon compte';

  @override
  String get signUpHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get signUpSignInLink => 'Se connecter';

  @override
  String codeSentToEmail(String email) {
    return 'Envoyé à $email.';
  }

  @override
  String get codeChangeEmail => 'Changer d’adresse';

  @override
  String get forgotTitle => 'Mot de passe oublié';

  @override
  String get forgotLead =>
      'Entre ton e-mail : on t’envoie un code pour choisir un nouveau mot de passe.';

  @override
  String get forgotButton => 'Envoyer le code';

  @override
  String get newPasswordTitle => 'Nouveau mot de passe';

  @override
  String get newPasswordLead =>
      'Choisis un mot de passe que tu n’utilises pas ailleurs.';

  @override
  String get newPasswordButton => 'Enregistrer';

  @override
  String get authConsent =>
      'J’accepte les conditions d’utilisation et la politique de confidentialité.';

  @override
  String get authTerms => 'conditions d’utilisation';

  @override
  String get authPrivacy => 'politique de confidentialité';

  @override
  String get codeLinkHint =>
      'Tu as reçu un lien plutôt qu’un code ? Ouvre-le sur ce téléphone.';
}

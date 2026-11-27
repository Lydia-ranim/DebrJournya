// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'DebrJournya';

  @override
  String get splashTagline => 'عمل يناسب جدولك الزمني';

  @override
  String get mascotLabel => 'جوبي، تميمة التطبيق';

  @override
  String get loadingLabel => 'جارٍ التحميل';

  @override
  String get commonComingSoon => 'قريبًا';

  @override
  String get languageTitle => 'اختر لغتك';

  @override
  String get languageLead => 'يمكنك تغييرها في أي وقت من الإعدادات.';

  @override
  String get languageTileLabel => 'ع';

  @override
  String get languageName => 'العربية';

  @override
  String get languageDescription =>
      'التطبيق كاملاً بالعربية، من اليمين إلى اليسار.';

  @override
  String get onboardingSkip => 'تخطٍّ';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'ابدأ';

  @override
  String get onboarding1Title => 'اعثر على عمل مرن';

  @override
  String get onboarding1Lead =>
      'مهام ووظائف وفعاليات بالقرب منك، تتماشى مع أوقات دراستك.';

  @override
  String get onboarding2Title => 'املأ أوقات فراغك بسرعة';

  @override
  String get onboarding2Lead =>
      'حدّد أوقات فراغك مرة واحدة، وسنقترح عليك ما يناسبك تمامًا.';

  @override
  String get onboarding3Title => 'ابنِ سيرتك الذاتية';

  @override
  String get onboarding3Lead =>
      'كل مهمة تُنجزها تُضاف تلقائيًا إلى سيرتك الذاتية، جاهزة للإرسال.';

  @override
  String onboardingProgress(int current, int total) {
    return 'الصفحة $current من $total';
  }
}

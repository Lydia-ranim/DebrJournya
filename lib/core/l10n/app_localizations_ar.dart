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

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonNoConnection => 'لا يوجد اتصال. حاول بعد قليل.';

  @override
  String get commonSignOut => 'تسجيل الخروج';

  @override
  String get commonTooManyRequests => 'طلبات كثيرة جدًا. حاول بعد بضع دقائق.';

  @override
  String get codeTitle => 'أدخل الرمز';

  @override
  String get codeFieldLabel => 'رمز من 6 أرقام';

  @override
  String codeResendIn(String time) {
    return 'إعادة إرسال الرمز بعد $time';
  }

  @override
  String get codeResend => 'أعد إرسال الرمز';

  @override
  String get codeVerify => 'تحقّق';

  @override
  String codeWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'رمز غير صحيح، بقيت لك $count محاولة.',
      few: 'رمز غير صحيح، بقيت لك $count محاولات.',
      two: 'رمز غير صحيح، بقيت لك محاولتان.',
      one: 'رمز غير صحيح، بقيت لك محاولة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get codeNoTriesLeft => 'محاولات كثيرة. اطلب رمزًا جديدًا.';

  @override
  String get codeExpired => 'انتهت صلاحية الرمز، اطلب رمزًا جديدًا.';

  @override
  String get roleTitle1 => 'مرحبًا بك!';

  @override
  String get roleTitle2 => 'ما الذي تبحث عنه هنا؟';

  @override
  String get roleLead => 'يمكنك إضافة الدور الآخر لاحقًا.';

  @override
  String get roleStudentTitle => 'أبحث عن عمل';

  @override
  String get roleStudentText => 'وظائف ومهام وتطوع تناسب جدولك الزمني.';

  @override
  String get roleEmployerTitle => 'أوظّف';

  @override
  String get roleEmployerText => 'انشر إعلانًا واعثر على طلاب متاحين في دقائق.';

  @override
  String get commonUnexpectedError => 'حدث خطأ ما. حاول مرة أخرى بعد قليل.';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHelper => '8 أحرف على الأقل.';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authOr => 'أو';

  @override
  String get authWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get authWithFacebook => 'المتابعة باستخدام Facebook';

  @override
  String get authInvalidEmail => 'عنوان بريد إلكتروني غير صالح.';

  @override
  String get authPasswordTooShort =>
      'يجب أن تتكوّن كلمة المرور من 8 أحرف على الأقل.';

  @override
  String get authWrongCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authEmailTaken => 'يوجد حساب بهذا البريد بالفعل. سجّل دخولك.';

  @override
  String get signInTitle => 'سعداء بعودتك';

  @override
  String get signInLead => 'سجّل دخولك لتجد عروضك وطلباتك.';

  @override
  String get signInForgot => 'نسيت كلمة المرور؟';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get signInNoAccount => 'ليس لديك حساب؟ أنشئ حسابًا';

  @override
  String get signInCreateLink => 'أنشئ حسابًا';

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get signUpLead =>
      'يكفي بريد إلكتروني وكلمة مرور. سنرسل إليك رمزًا للتحقق من عنوانك.';

  @override
  String get signUpButton => 'إنشاء حسابي';

  @override
  String get signUpHaveAccount => 'لديك حساب؟ سجّل دخولك';

  @override
  String get signUpSignInLink => 'سجّل دخولك';

  @override
  String codeSentToEmail(String email) {
    return 'أُرسل إلى $email.';
  }

  @override
  String get codeChangeEmail => 'تغيير العنوان';

  @override
  String get forgotTitle => 'نسيت كلمة المرور';

  @override
  String get forgotLead =>
      'أدخل بريدك الإلكتروني وسنرسل إليك رمزًا لاختيار كلمة مرور جديدة.';

  @override
  String get forgotButton => 'أرسل الرمز';

  @override
  String get newPasswordTitle => 'كلمة مرور جديدة';

  @override
  String get newPasswordLead => 'اختر كلمة مرور لا تستخدمها في مكان آخر.';

  @override
  String get newPasswordButton => 'حفظ';

  @override
  String get authConsent => 'أوافق على شروط الاستخدام وعلى سياسة الخصوصية.';

  @override
  String get authTerms => 'شروط الاستخدام';

  @override
  String get authPrivacy => 'سياسة الخصوصية';

  @override
  String get codeLinkHint => 'وصلك رابط بدل الرمز؟ افتحه على هذا الهاتف.';
}

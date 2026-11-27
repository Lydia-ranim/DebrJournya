import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/preferences.dart';

/// The language the user picked (A3 · Langue, later D2 · Réglages), saved on
/// the device. `null` means "not chosen yet": the app then follows the phone
/// (Arabic if the phone is in Arabic, French otherwise, see [resolveLocale]).
final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref
        .watch(sharedPreferencesProvider)
        .getString(PrefKeys.languageCode);
    return code == null ? null : Locale(code);
  }

  Future<void> choose(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(PrefKeys.languageCode, locale.languageCode);
  }
}

/// Device-language fallback used until the user picks a language.
Locale resolveLocale(Locale? device, Iterable<Locale> supported) {
  if (device?.languageCode == 'ar') return const Locale('ar');
  return const Locale('fr');
}

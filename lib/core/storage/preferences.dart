import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's [SharedPreferences], loaded once in `main()` and injected with
/// `sharedPreferencesProvider.overrideWithValue(prefs)` (tests do the same
/// with `SharedPreferences.setMockInitialValues`).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override sharedPreferencesProvider'),
);

/// Keys of everything stored on the device, in one place.
abstract final class PrefKeys {
  static const languageCode = 'languageCode';
  static const onboardingSeen = 'onboardingSeen';
}

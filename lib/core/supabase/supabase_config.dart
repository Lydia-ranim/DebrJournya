/// Supabase connection settings, passed at run time (never in the code):
/// `flutter run --dart-define-from-file=env/dev.json` (see env/dev.example.json).
/// Without them the app runs on the fake repositories (tests, previews).
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}

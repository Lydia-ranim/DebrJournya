/// Checks done on the phone before calling the server.
abstract final class Credentials {
  static const minPasswordLength = 8;

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String normalizeEmail(String input) => input.trim().toLowerCase();

  static bool isEmail(String input) => _email.hasMatch(normalizeEmail(input));

  static bool isStrongEnough(String password) =>
      password.length >= minPasswordLength;
}

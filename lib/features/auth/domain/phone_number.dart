import 'package:flutter/services.dart';

/// Algerian mobile numbers: 9 digits starting with 5, 6 or 7 after the
/// country code (+213). People usually type them with a leading 0
/// ("0661 23 45 67"), which is accepted and dropped.
abstract final class AlgerianPhone {
  static const countryCode = '+213';

  static final _national = RegExp(r'^[567]\d{8}$');

  /// The digits of [input] without the leading 0 or a pasted "213" prefix.
  static String national(String input) {
    var d = input.replaceAll(RegExp(r'\D'), '');
    if (d.length == 12 && d.startsWith('213')) d = d.substring(3);
    if (d.startsWith('0')) d = d.substring(1);
    return d;
  }

  static bool isValid(String input) => _national.hasMatch(national(input));

  /// International form (`+213661234567`), or null when [input] is invalid.
  static String? toE164(String input) =>
      isValid(input) ? '$countryCode${national(input)}' : null;

  /// Groups digits the way they are said: `0661 23 45 67` / `661 23 45 67`.
  static String group(String digits) {
    final first = digits.startsWith('0') ? 4 : 3;
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == first || (i > first && (i - first) % 2 == 0)) out.write(' ');
      out.write(digits[i]);
    }
    return out.toString();
  }

  /// Most digits a field may hold: 10 with the leading 0, else 9.
  static int maxDigits(String digits) => digits.startsWith('0') ? 10 : 9;
}

/// Keeps only digits, caps the length and groups them as you type.
/// A pasted international number (`+213 661…`) is turned into its local
/// form.
class AlgerianPhoneFormatter extends TextInputFormatter {
  const AlgerianPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10 && digits.startsWith('213')) {
      digits = '0${digits.substring(3)}';
    }
    final max = AlgerianPhone.maxDigits(digits);
    if (digits.length > max) digits = digits.substring(0, max);

    // Keep the cursor after the same number of digits as before formatting.
    final cursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    var digitsBefore = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    if (digitsBefore > digits.length) digitsBefore = digits.length;

    final text = AlgerianPhone.group(digits);
    var offset = 0;
    for (var seen = 0; offset < text.length && seen < digitsBefore; offset++) {
      if (text[offset] != ' ') seen++;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

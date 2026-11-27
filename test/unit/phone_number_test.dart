import 'package:debrjournya/features/auth/domain/phone_number.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlgerianPhone.isValid', () {
    test('accepts mobiles starting with 5, 6 or 7, with or without the 0', () {
      for (final n in [
        '0661234567',
        '661234567',
        '0551 23 45 67',
        '0771234567',
        '+213 661 23 45 67',
        '213661234567',
      ]) {
        expect(AlgerianPhone.isValid(n), isTrue, reason: n);
      }
    });

    test('rejects landlines, short and long numbers, empty input', () {
      for (final n in [
        '',
        '06612',
        '0261234567', // landline (starts with 2)
        '0861234567',
        '06612345678', // one digit too many
        '66123456', // one digit short
        'abc',
      ]) {
        expect(AlgerianPhone.isValid(n), isFalse, reason: n);
      }
    });
  });

  test('toE164 gives +213 without the leading 0', () {
    expect(AlgerianPhone.toE164('0661 23 45 67'), '+213661234567');
    expect(AlgerianPhone.toE164('0261234567'), isNull);
  });

  test('group splits like the mockup', () {
    expect(AlgerianPhone.group('0661234567'), '0661 23 45 67');
    expect(AlgerianPhone.group('661234567'), '661 23 45 67');
    expect(AlgerianPhone.group('06612'), '0661 2');
    expect(AlgerianPhone.group(''), '');
  });

  group('AlgerianPhoneFormatter', () {
    const f = AlgerianPhoneFormatter();
    TextEditingValue type(String text) => f.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );

    test('keeps digits only and groups them', () {
      final v = type('06a6-1 2345 67');
      expect(v.text, '0661 23 45 67');
      expect(v.selection.baseOffset, v.text.length);
    });

    test('caps the length (10 with the 0, 9 without)', () {
      expect(type('066123456789').text, '0661 23 45 67');
      expect(type('6612345678').text, '661 23 45 67');
    });

    test('a pasted +213 number becomes local', () {
      expect(type('+213661234567').text, '0661 23 45 67');
    });

    test(
      'the cursor stays after the same digit when editing in the middle',
      () {
        // Insert "9" after "0661" in "0661 23".
        final v = f.formatEditUpdate(
          const TextEditingValue(text: '0661 23'),
          const TextEditingValue(
            text: '06619 23',
            selection: TextSelection.collapsed(offset: 5),
          ),
        );
        expect(v.text, '0661 92 3');
        expect(v.selection.baseOffset, 6);
      },
    );
  });
}

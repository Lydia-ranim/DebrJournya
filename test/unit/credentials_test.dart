import 'package:debrjournya/features/auth/domain/credentials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('e-mail check', () {
    for (final ok in ['a@b.co', ' Amina.B@Univ-Batna.dz ', 'x+tag@mail.com']) {
      expect(Credentials.isEmail(ok), isTrue, reason: ok);
    }
    for (final bad in ['', 'amina', 'a@b', 'a b@c.com', '@c.com', 'a@.c']) {
      expect(Credentials.isEmail(bad), isFalse, reason: bad);
    }
  });

  test('e-mails are trimmed and lower-cased', () {
    expect(Credentials.normalizeEmail('  Amina@Mail.COM '), 'amina@mail.com');
  });

  test('passwords need 8 characters', () {
    expect(Credentials.isStrongEnough('1234567'), isFalse);
    expect(Credentials.isStrongEnough('12345678'), isTrue);
  });
}

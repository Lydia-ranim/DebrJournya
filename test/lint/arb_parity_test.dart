// French is the template; every string must exist in Arabic with the same
// placeholders, and no translation may be left empty.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _read(String lang) =>
    jsonDecode(File('lib/core/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

/// `{name}` and the variable of `{name, plural, …}` — not the words that
/// start an ICU sub-message such as `=1{Code incorrect…}`.
Set<String> _placeholders(String text) =>
    RegExp(r'\{(\w+)\s*[},]').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  final fr = _read('fr');
  final ar = _read('ar');

  test('Arabic has exactly the French keys', () {
    expect(_keys(ar).difference(_keys(fr)), isEmpty, reason: 'only in AR');
    expect(_keys(fr).difference(_keys(ar)), isEmpty, reason: 'missing in AR');
  });

  test('every French string documents where it is used', () {
    final undocumented = _keys(fr)
        .where((k) => (fr['@$k'] as Map?)?['description'] == null);
    expect(undocumented, isEmpty);
  });

  test('placeholders match and nothing is empty', () {
    for (final key in _keys(fr)) {
      final f = fr[key] as String;
      final a = ar[key] as String?;
      expect(a, isNotNull, reason: key);
      expect(a!.trim(), isNotEmpty, reason: key);
      expect(_placeholders(a), _placeholders(f), reason: key);
    }
  });
}

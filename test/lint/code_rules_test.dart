// Project rules that the analyzer can't check, enforced as tests so a slip
// fails `flutter test` instead of reaching a review:
//  - screens use theme tokens (dark mode) and directional layout (Arabic RTL);
//  - no user-facing text is hard-coded (everything goes through the ARB files).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Pattern → why it is not allowed in `lib/features/**`.
final _rules = <RegExp, String>{
  RegExp(r'\bColor\(0x'): 'raw colour: use context.colors',
  RegExp(r'\bColors\.(?!transparent\b)'): 'Material colour: use context.colors',
  RegExp(r'EdgeInsets\.only\([^)]*\b(left|right):'):
      'left/right padding: use EdgeInsetsDirectional',
  RegExp(r'EdgeInsets\.fromLTRB'): 'LTRB padding: use EdgeInsetsDirectional',
  RegExp(
    r'Alignment\.(centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)',
  ): 'left/right alignment: use AlignmentDirectional',
  RegExp(r'\bPositioned\([^)]*\b(left|right):'):
      'left/right position: use PositionedDirectional',
  RegExp(r'TextAlign\.(left|right)'):
      'left/right text: use TextAlign.start/end',
  RegExp(r'\bTextStyle\('): 'ad-hoc text style: use context.type',
  RegExp(r'''\bText\(\s*['"]'''): 'hard-coded text: add an ARB key',
  RegExp(r'''(label|hintText|labelText|tooltip|semanticsLabel):\s*['"]'''):
      'hard-coded text: add an ARB key',
};

/// Lines allowed to break a rule, with the reason (keep this list short).
const _allowed = <String>[
  // The brand mascot keeps its own colours in both themes.
  'lib/features/mascot/',
];

void main() {
  test('screens use tokens, directional layout and localised text', () {
    final problems = <String>[];
    final files = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      if (_allowed.any(path.contains)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        _rules.forEach((pattern, why) {
          if (pattern.hasMatch(line)) {
            problems.add('$path:${i + 1}  $why\n    ${line.trim()}');
          }
        });
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}

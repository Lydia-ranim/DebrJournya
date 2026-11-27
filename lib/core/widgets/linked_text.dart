import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// A paragraph in which some parts are links (bold and underlined).
/// [text] must contain each key of [links] once; that part becomes tappable.
class LinkedText extends StatefulWidget {
  const LinkedText({
    super.key,
    required this.text,
    required this.links,
    this.emphasis = const {},
    this.style,
  });

  final String text;
  final Map<String, VoidCallback> links;

  /// Parts shown in bold without being links (e.g. a phone number).
  final Set<String> emphasis;

  /// Defaults to `context.type.control`.
  final TextStyle? style;

  @override
  State<LinkedText> createState() => _LinkedTextState();
}

class _LinkedTextState extends State<LinkedText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final style = widget.style ?? context.type.control;
    final boldStyle = style.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w800,
      fontVariations: const [FontVariation('wght', 800)],
    );
    final linkStyle = boldStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationThickness: 1.6,
    );

    // Cut the text at each link or bold part, in the order they appear.
    final parts = <String, VoidCallback?>{
      for (final e in widget.emphasis) e: null,
      ...widget.links,
    };
    final found = [
      for (final e in parts.entries)
        if (widget.text.contains(e.key)) (widget.text.indexOf(e.key), e),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    final spans = <InlineSpan>[];
    var at = 0;
    for (final (index, part) in found) {
      if (index < at) continue;
      spans.add(TextSpan(text: widget.text.substring(at, index)));
      final onTap = part.value;
      if (onTap == null) {
        spans.add(TextSpan(text: part.key, style: boldStyle));
      } else {
        final r = TapGestureRecognizer()..onTap = onTap;
        _recognizers.add(r);
        spans.add(TextSpan(text: part.key, style: linkStyle, recognizer: r));
      }
      at = index + part.key.length;
    }
    spans.add(TextSpan(text: widget.text.substring(at)));

    return Text.rich(TextSpan(style: style, children: spans));
  }
}

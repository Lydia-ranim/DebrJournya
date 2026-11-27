import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Screen title block for screens without a top bar: one or more big title
/// lines and an optional lead paragraph (A3, A6).
///
/// Each title line may carry its own [TextDirection] — A3 shows a French and
/// an Arabic line whatever the app language.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.titles, this.lead});

  final List<HeaderLine> titles;
  final String? lead;

  static const _titleToLead = 11.0;

  @override
  Widget build(BuildContext context) {
    final type = context.type;
    // A line written in the other direction still sits on this page's
    // reading side (the Arabic line of A3 is left-aligned on a French page).
    final align = Directionality.of(context) == TextDirection.ltr
        ? TextAlign.left
        : TextAlign.right;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final t in titles)
          Text(
            t.text,
            style: type.display,
            textDirection: t.direction,
            textAlign: align,
          ),
        if (lead != null) ...[
          const SizedBox(height: _titleToLead),
          Text(lead!, style: type.lead),
        ],
      ],
    );
  }
}

class HeaderLine {
  const HeaderLine(this.text, {this.direction});

  final String text;
  final TextDirection? direction;
}

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Plain bold text button, e.g. "Passer" in a header. Keeps a 48-pt-high
/// tap target while drawing only the text.
class TextAction extends StatelessWidget {
  const TextAction({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const _hitPadding = EdgeInsets.symmetric(
    horizontal: Space.sm,
    vertical: Space.md,
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Padding(
          padding: _hitPadding,
          child: Text(label, style: context.type.action),
        ),
      ),
    );
  }
}

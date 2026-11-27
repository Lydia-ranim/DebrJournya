import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Thin line with a word in the middle ("ou") between two ways of doing
/// the same thing.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: Sizes.border, color: context.colors.line),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
          child: Text(label, style: context.type.caption),
        ),
        line,
      ],
    );
  }
}

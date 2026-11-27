import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// 44-pt round button with a thin border, e.g. the back button on A4.
/// Pass a `…Dir` Lucide icon so it mirrors in Arabic.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Spoken by screen readers and shown on long press.
  final String tooltip;

  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        child: Material(
          color: c.surface,
          shape: CircleBorder(side: BorderSide(color: c.line)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: Sizes.roundButton,
              child: Icon(icon, size: _iconSize, color: c.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

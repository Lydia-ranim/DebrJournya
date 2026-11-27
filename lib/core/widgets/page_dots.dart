import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Page indicator: one dot per page, the current one stretched into a pill.
/// Order follows the reading direction (right-to-left in Arabic).
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.current,
    this.semanticsLabel,
  });

  final int count;
  final int current;

  /// e.g. "Page 2 sur 3".
  final String? semanticsLabel;

  static const _dot = 8.0;
  static const _active = 24.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: i == current ? _active : _dot,
              height: _dot,
              decoration: BoxDecoration(
                color: i == current ? c.primary : c.dotInactive,
                borderRadius: BorderRadius.circular(_dot / 2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

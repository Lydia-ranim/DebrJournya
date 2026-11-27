import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The "DebrJournya" logotype: "Debr" in ink, "Journya" in the brand accent.
/// Always Latin and left-to-right, also in the Arabic UI.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = appText(
      size: size,
      weight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.02 * size,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(
            text: 'Debr',
            style: TextStyle(color: c.textPrimary),
          ),
          TextSpan(
            text: 'Journya',
            style: TextStyle(color: c.brandAccent),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      semanticsLabel: 'DebrJournya',
    );
  }
}

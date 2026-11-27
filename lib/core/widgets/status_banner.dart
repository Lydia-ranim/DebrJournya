import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Dark rounded banner with an icon and a short message, shown at the top
/// of a screen (e.g. "Pas de connexion. Réessaie dans un instant.").
/// Announced to screen readers when it appears.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  static const _height = 47.0;
  static const _radius = 16.0;
  static const _iconSize = 16.5;
  static const _padding = EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8);
  static const _gap = 11.5;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: c.primary,
        borderRadius: const BorderRadius.all(Radius.circular(_radius)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _height),
          child: Padding(
            padding: _padding,
            child: Row(
              children: [
                Icon(icon, size: _iconSize, color: c.onPrimary),
                const SizedBox(width: _gap),
                Expanded(child: Text(message, style: context.type.banner)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

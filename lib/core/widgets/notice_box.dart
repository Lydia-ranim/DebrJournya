import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Soft red box with an alert icon for an error that concerns the whole
/// screen (A5 "Code incorrect…"). Announced to screen readers.
class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.message});

  final String message;

  static const _padding = EdgeInsetsDirectional.fromSTEB(14, 16, 18, 16);
  static const _iconSize = 19.0;
  static const _gap = 11.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: _padding,
        decoration: BoxDecoration(
          color: c.dangerSoft,
          borderRadius: const BorderRadius.all(Radius.circular(Radii.field)),
          border: Border.all(color: c.dangerLine),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.circleAlert, size: _iconSize, color: c.danger),
            const SizedBox(width: _gap),
            Expanded(child: Text(message, style: context.type.control)),
          ],
        ),
      ),
    );
  }
}

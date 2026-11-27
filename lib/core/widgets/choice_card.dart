import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'app_card.dart';
import 'icon_tile.dart';

/// Big tappable option card: icon tile, title, description and a round
/// "go" button aligned with the last line (A3 · Langue, A6 · Choix du rôle).
/// The whole card is the tap target.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.tileColor,
    required this.tile,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Color tileColor;
  final Widget tile;
  final String title;
  final String description;
  final VoidCallback onTap;

  static const _tileToTitle = 16.0;
  static const _titleToText = 7.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final type = context.type;
    return Semantics(
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(color: tileColor, child: tile),
            const SizedBox(height: _tileToTitle),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: type.cardTitle),
                      const SizedBox(height: _titleToText),
                      Text(description, style: type.body),
                    ],
                  ),
                ),
                const SizedBox(width: Space.lg),
                Container(
                  width: Sizes.roundButton,
                  height: Sizes.roundButton,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                  ),
                  // "Dir" icons mirror automatically in right-to-left text.
                  child: Icon(
                    LucideIcons.chevronRightDir,
                    size: Sizes.iconSmall,
                    color: c.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Rounded square tile holding an icon or a short label ("FR", "ع").
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.color,
    required this.child,
    this.size = Sizes.tile,
  });

  final Color color;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(Radii.tile)),
      ),
      child: child,
    );
  }
}

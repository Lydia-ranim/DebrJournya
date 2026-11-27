import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Outlined full-width button with a brand logo ("Continuer avec Google").
/// Logos are the official brand marks in `assets/brand/social/`.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.logo,
    required this.label,
    required this.onPressed,
  });

  /// Asset path of the logo SVG.
  final String logo;
  final String label;
  final VoidCallback? onPressed;

  static const google = 'assets/brand/social/google.svg';
  static const facebook = 'assets/brand/social/facebook.svg';

  static const _logoSize = 20.0;
  static const _gap = 10.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        width: double.infinity,
        height: Sizes.button,
        child: Material(
          color: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(Radii.button)),
            side: BorderSide(color: c.fieldBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: SvgPicture.asset(
                    logo,
                    width: _logoSize,
                    height: _logoSize,
                  ),
                ),
                const SizedBox(width: _gap),
                Flexible(
                  child: Text(
                    label,
                    style: context.type.button.copyWith(color: c.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'loading_dots.dart';

/// Filled main-action button: soot in light mode, sage in dark mode,
/// 52 pt tall, rounded. Full width unless [width] is given. An optional
/// [icon] sits before the label (use `…Dir` Lucide icons so arrows mirror
/// in Arabic). Disabled when [onPressed] is null.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  /// Shows the loading dots instead of the label (taps are ignored).
  final bool loading;

  static const _iconGap = 10.0;
  static const _iconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    final fg = c.onPrimary;
    return Semantics(
      button: true,
      enabled: enabled,
      child: SizedBox(
        width: width ?? double.infinity,
        height: Sizes.button,
        child: Material(
          color: enabled ? c.primary : c.primary.withValues(alpha: 0.4),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Radii.button)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: loading ? null : onPressed,
            child: loading
                ? Center(child: LoadingDots(colors: [fg, fg, fg]))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: _iconSize, color: fg),
                        const SizedBox(width: _iconGap),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          style: context.type.button.copyWith(color: fg),
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

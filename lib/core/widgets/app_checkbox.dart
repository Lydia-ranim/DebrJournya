import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';

/// Square rounded checkbox (filled with the primary colour when ticked)
/// followed by a [label]. Tapping the box or the label's plain text toggles
/// it; links inside the label keep their own taps.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;

  static const _box = 22.0;
  static const _radius = 6.5;
  static const _tick = 15.0;
  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    void toggle() => onChanged(!value);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          checked: value,
          onTap: toggle,
          child: GestureDetector(
            onTap: toggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: _box,
              height: _box,
              decoration: BoxDecoration(
                color: value ? c.primary : c.surface,
                borderRadius: const BorderRadius.all(Radius.circular(_radius)),
                border: value
                    ? null
                    : Border.all(color: c.fieldBorder, width: 1.5),
              ),
              child: value
                  ? Icon(LucideIcons.check, size: _tick, color: c.onPrimary)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: GestureDetector(
            onTap: toggle,
            behavior: HitTestBehavior.opaque,
            child: label,
          ),
        ),
      ],
    );
  }
}

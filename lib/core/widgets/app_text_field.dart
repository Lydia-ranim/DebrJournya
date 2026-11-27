import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Form field from the mockups: bold label above, 52-pt white box with a
/// thin border, optional fixed [prefix] ("+213") followed by a divider, and
/// an [error] line with an alert icon under it (border turns red).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.prefix,
    this.error,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.forceLtr = false,
    this.obscureText = false,
    this.suffix,
    this.helper,
  });

  final String label;
  final TextEditingController controller;
  final String? prefix;
  final String? error;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  /// Keep the box left-to-right in Arabic (phone numbers, e-mails).
  final bool forceLtr;

  /// Hides the text (passwords).
  final bool obscureText;

  /// Widget at the end of the box (e.g. the show-password eye).
  final Widget? suffix;

  /// Grey hint line under the field, replaced by [error] when there is one.
  final String? helper;

  static const _labelGap = 5.5;
  static const _prefixPadding = EdgeInsetsDirectional.only(start: 15, end: 11);
  static const _dividerHeight = 30.0;
  static const _inputStart = 13.0;
  static const _inputEnd = 16.0;
  static const _errorGap = 8.0;
  static const _errorIcon = 17.0;
  static const _errorIconGap = 5.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final type = context.type;
    final hasError = error != null;
    final borderColor = hasError ? c.danger : c.fieldBorder;

    Widget box = Container(
      height: Sizes.button,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.all(Radius.circular(Radii.field)),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (prefix != null) ...[
            Padding(
              padding: _prefixPadding,
              child: Text(prefix!, style: type.inputPrefix),
            ),
            Container(
              width: Sizes.border,
              height: _dividerHeight,
              color: c.line,
            ),
          ],
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: prefix != null ? _inputStart : _inputEnd,
                end: _inputEnd,
              ),
              child: TextField(
                controller: controller,
                style: type.input,
                cursorColor: c.textPrimary,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                textInputAction: textInputAction,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                autofillHints: autofillHints,
                obscureText: obscureText,
                autocorrect: !obscureText,
                enableSuggestions: !obscureText,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: type.input.copyWith(
                    color: c.textSecondary.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
    if (forceLtr) {
      box = Directionality(textDirection: TextDirection.ltr, child: box);
    }

    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Text(label, style: type.fieldLabel)),
          const SizedBox(height: _labelGap),
          box,
          if (hasError) ...[
            const SizedBox(height: _errorGap),
            Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: _errorIcon,
                    color: c.danger,
                  ),
                  const SizedBox(width: _errorIconGap),
                  Expanded(
                    child: Text(
                      error!,
                      style: type.caption.copyWith(color: c.danger),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (helper != null) ...[
            const SizedBox(height: _errorGap),
            Text(helper!, style: type.caption),
          ],
        ],
      ),
    );
  }
}

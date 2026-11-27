import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Row of boxes for a numeric code (A5: 6 digits). One hidden text field
/// takes the input, so typing, deleting, pasting and SMS autofill all work;
/// the boxes only display it. The next box to fill has a dark border.
/// Digits stay left to right in Arabic.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.error = false,
    this.enabled = true,
    this.autofocus = false,
    this.semanticsLabel,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  /// Red borders (wrong code).
  final bool error;
  final bool enabled;
  final bool autofocus;
  final String? semanticsLabel;

  static const _height = 57.5;
  static const _gap = 13.0;
  static const _radius = 16.0;
  static const _activeBorder = 2.0;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = widget.controller.text;
    final active = _focus.hasFocus ? text.length : -1;

    Widget box(int i) {
      final isActive = i == active && i < widget.length;
      final Color border;
      if (widget.error) {
        border = c.danger;
      } else if (isActive) {
        border = c.primary;
      } else {
        border = c.fieldBorder;
      }
      return Expanded(
        child: Container(
          height: CodeInput._height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.all(
              Radius.circular(CodeInput._radius),
            ),
            border: Border.all(
              color: border,
              width: isActive ? CodeInput._activeBorder : Sizes.border,
            ),
          ),
          child: Text(
            i < text.length ? text[i] : '',
            style: context.type.codeDigit,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Semantics(
        label: widget.semanticsLabel,
        textField: true,
        value: text,
        child: GestureDetector(
          onTap: widget.enabled ? _focus.requestFocus : null,
          child: Stack(
            children: [
              ExcludeSemantics(
                child: Row(
                  children: [
                    for (var i = 0; i < widget.length; i++) ...[
                      if (i > 0) const SizedBox(width: CodeInput._gap),
                      box(i),
                    ],
                  ],
                ),
              ),
              // The real input, invisible, over the boxes.
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    showCursor: false,
                    enableInteractiveSelection: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    onChanged: (v) {
                      widget.onChanged?.call(v);
                      if (v.length == widget.length) {
                        widget.onCompleted?.call(v);
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

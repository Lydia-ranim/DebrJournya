import 'package:flutter/material.dart';

import '../../features/mascot/jobby.dart';
import 'wordmark.dart';

/// Small logo row: still Jobby + wordmark, with an optional [trailing]
/// widget at the end side (e.g. "Passer" on A2).
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.trailing});

  final Widget? trailing;

  static const _jobby = 36.0;
  static const _gap = 6.0;
  static const _wordmark = 18.0;

  // The mascot's artwork sits a little low in its box: lift it so it lines
  // up with the text, as in the mockups.
  static const _jobbyLift = Offset(0, -2.5);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // The mascot artwork faces right; it is a logo, so it never mirrors.
        Transform.translate(
          offset: _jobbyLift,
          child: const Jobby(
            size: _jobby,
            state: JobbyState.working,
            animate: false,
            interactive: false,
            stillTime: 1.3,
          ),
        ),
        const SizedBox(width: _gap),
        const Wordmark(size: _wordmark),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

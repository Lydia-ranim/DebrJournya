import 'package:flutter/material.dart';

import '../../../core/config/features.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/or_divider.dart';
import '../../../core/widgets/social_button.dart';
import '../data/auth_repository.dart';
import 'auth_layout.dart';

/// "ou" + "Continuer avec Google" (+ "Continuer avec Facebook" when
/// [Features.facebookLogin] is on).
class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.showFacebook = Features.facebookLogin,
  });

  final ValueChanged<SocialProvider> onPressed;
  final bool enabled;
  final bool showFacebook;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: AuthGaps.aroundDivider),
        OrDivider(label: l.authOr),
        const SizedBox(height: AuthGaps.aroundDivider),
        SocialButton(
          logo: SocialButton.google,
          label: l.authWithGoogle,
          onPressed: enabled ? () => onPressed(SocialProvider.google) : null,
        ),
        if (showFacebook) ...[
          const SizedBox(height: AuthGaps.between),
          SocialButton(
            logo: SocialButton.facebook,
            label: l.authWithFacebook,
            onPressed: enabled
                ? () => onPressed(SocialProvider.facebook)
                : null,
          ),
        ],
      ],
    );
  }
}

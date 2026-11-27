import 'package:flutter/widgets.dart';

import 'app_colors.dart';
import 'app_theme.dart';

/// Spacing scale (pt), measured from the 390-pt-wide mockups.
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;

  /// Horizontal margin of every screen.
  static const page = 20.0;

  /// Top margin of screens without a top bar (A3, A6…), below the safe area.
  static const pageTop = 36.0;

  /// Inner padding of an [AppCard], measured from its outer edge (the 1-pt
  /// border is drawn inside it).
  static const card = 23.0;
}

/// Corner radii (pt).
abstract final class Radii {
  static const card = 23.0;
  static const tile = 20.0;
  static const field = 18.0;
  static const button = 16.0;
  static const pill = 999.0;
}

/// Fixed component sizes (pt).
abstract final class Sizes {
  /// Square icon tile on choice cards (A3, A6).
  static const tile = 64.0;

  /// Round "go" button on choice cards.
  static const roundButton = 44.0;

  /// Height of full-width buttons.
  static const button = 52.0;

  static const icon = 24.0;
  static const iconSmall = 20.0;
  static const border = 1.0;
}

/// Named text styles with their theme colours, from `context.type`.
/// Screens use these instead of building [TextStyle]s, so sizes and colours
/// stay consistent and dark mode comes for free.
class AppTypography {
  AppTypography(this._c);

  final AppColors _c;

  /// Big screen title ("Choisis ta langue", "Bienvenue !").
  TextStyle get display => appText(
    size: 28,
    weight: FontWeight.w800,
    height: 1.37,
    letterSpacing: -0.6,
    color: _c.textPrimary,
  );

  /// Intro text under a screen title.
  TextStyle get lead => appText(
    size: 15,
    weight: FontWeight.w500,
    height: 1.37,
    letterSpacing: -0.2,
    color: _c.textSecondary,
  );

  /// Card title ("Français", "Je recrute").
  TextStyle get cardTitle => appText(
    size: 22,
    weight: FontWeight.w800,
    height: 1.3,
    letterSpacing: -0.3,
    color: _c.textPrimary,
  );

  /// Card / list secondary text.
  TextStyle get body => appText(
    size: 15,
    weight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.15,
    color: _c.textSecondary,
  );

  /// Hero title of a full-screen message (A2 slides).
  TextStyle get hero => appText(
    size: 28.5,
    weight: FontWeight.w800,
    height: 1.37,
    letterSpacing: -0.7,
    color: _c.textPrimary,
  );

  /// Larger lead paragraph under a hero title.
  TextStyle get leadLarge => appText(
    size: 16.3,
    weight: FontWeight.w500,
    height: 1.44,
    letterSpacing: -0.3,
    color: _c.textSecondary,
  );

  /// Label of filled buttons (colour set by the button).
  TextStyle get button => appText(
    size: 16.4,
    weight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
    color: _c.onPrimary,
  );

  /// Plain text action in a header ("Passer").
  TextStyle get action => appText(
    size: 15.3,
    weight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
    color: _c.textPrimary,
  );

  /// Big letters inside an icon tile ("FR", "ع").
  TextStyle get tileLabel => appText(
    size: 22,
    weight: FontWeight.w800,
    height: 1.2,
    color: _c.textPrimary,
  );
}

extension AppTypographyX on BuildContext {
  AppTypography get type => AppTypography(colors);
}

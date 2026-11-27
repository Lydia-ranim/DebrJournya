import 'package:flutter/material.dart';

/// Brand palette, measured from the mockups (`Docs/design`) and the mascot
/// file. Raw values live here; widgets read the themed set via
/// `context.colors` (see [AppColorsX]).
abstract final class Palette {
  static const soot = Color(0xFF2D3536);
  static const moss = Color(0xFF697C70);
  static const eucalyptus = Color(0xFF98AA9D);
  static const mist = Color(0xFFB3C9D6);
  static const plaster = Color(0xFFF2EFE2);
  static const ink = Color(0xFF111414);
  static const ink2 = Color(0xFF3E4544);
  static const line = Color(0xFFE9E5DA);
  static const cream = Color(0xFFFAF8F2);
  static const danger = Color(0xFFB5533C);
  static const dangerSoft = Color(0xFFF6E4DE);
  static const infoSoft = Color(0xFFE7EFF3);

  static const night = Color(0xFF0E1412);
  static const nightCard = Color(0xFF161E1B);
  static const nightLine = Color(0xFF23302B);
  static const nightInk = Color(0xFFE8E4D8);
  static const nightInk2 = Color(0xFFAEB8B2);
  static const sage = Color(0xFFA3B8A9);
  static const nightMoss = Color(0xFF7F9C88);
  static const nightPine = Color(0xFF3F5847);
  static const nightSlate = Color(0xFF34495A);
  static const nightDanger = Color(0xFFE3A08D);

  /// Mascot body green ("Jobby Pro").
  static const jobby = Color(0xFF5F8069);
}

/// Semantic colours that flip between light and dark mode.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.line,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.onPrimary,
    required this.brandAccent,
    required this.greenTile,
    required this.blueTile,
    required this.danger,
    required this.dangerSoft,
    required this.dangerLine,
    required this.infoSoft,
    required this.greenSoft,
    required this.skeleton,
    required this.fieldBorder,
    required this.dotInactive,
    required this.paper,
    required this.shadow,
    required this.loaderDots,
  });

  final Color background;
  final Color surface;
  final Color line;
  final Color textPrimary;
  final Color textSecondary;

  /// Main action colour (soot in light mode, sage in dark mode).
  final Color primary;
  final Color onPrimary;

  /// The "Journya" half of the wordmark.
  final Color brandAccent;

  /// Green icon tiles (FR in A3, "Je cherche" in A6), match pills.
  final Color greenTile;

  /// Blue icon tiles (AR in A3, "Je recrute" in A6), unpaid tags.
  final Color blueTile;
  final Color danger;
  final Color dangerSoft;

  /// Border of danger-soft boxes (error notices).
  final Color dangerLine;
  final Color infoSoft;

  /// Soft green panel behind illustrations (A2 slides 1 and 3).
  final Color greenSoft;

  /// Placeholder text bars in illustrations and loading skeletons.
  final Color skeleton;

  /// Border of text fields and unticked checkboxes (stronger than [line]).
  final Color fieldBorder;

  /// Inactive page dots (A2).
  final Color dotInactive;

  /// Printed-paper white (the CV sheet stays white in dark mode, as designed).
  final Color paper;

  /// Soft drop shadow under floating cards.
  final Color shadow;

  /// The three splash/loader dots, start to end.
  final List<Color> loaderDots;

  static const light = AppColors(
    background: Palette.cream,
    surface: Colors.white,
    line: Palette.line,
    textPrimary: Palette.ink,
    textSecondary: Palette.ink2,
    primary: Palette.soot,
    onPrimary: Palette.cream,
    brandAccent: Palette.moss,
    greenTile: Palette.eucalyptus,
    blueTile: Palette.mist,
    danger: Palette.danger,
    dangerSoft: Palette.dangerSoft,
    dangerLine: Color(0xFFEDCDC3),
    infoSoft: Palette.infoSoft,
    greenSoft: Color(0xFFE8EDE9),
    skeleton: Color(0xFFD3CEBF),
    fieldBorder: Color(0xFFD3CEBF),
    dotInactive: Color(0xFFCBC6B6),
    paper: Colors.white,
    shadow: Color(0x1A2D3536),
    loaderDots: [Palette.soot, Palette.moss, Palette.eucalyptus],
  );

  static const dark = AppColors(
    background: Palette.night,
    surface: Palette.nightCard,
    line: Palette.nightLine,
    textPrimary: Palette.nightInk,
    textSecondary: Palette.nightInk2,
    primary: Palette.sage,
    onPrimary: Palette.night,
    brandAccent: Palette.nightMoss,
    greenTile: Palette.nightPine,
    blueTile: Palette.nightSlate,
    danger: Palette.nightDanger,
    dangerSoft: Color(0xFF2E1F1C),
    dangerLine: Color(0xFF55352D),
    infoSoft: Color(0xFF18232B),
    greenSoft: Color(0xFF1C2923),
    skeleton: Color(0xFF2E3D36),
    fieldBorder: Color(0xFF2E3D36),
    dotInactive: Color(0xFF3A4A42),
    paper: Colors.white,
    shadow: Color(0x66000000),
    loaderDots: [Palette.sage, Palette.nightMoss, Palette.nightPine],
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? line,
    Color? textPrimary,
    Color? textSecondary,
    Color? primary,
    Color? onPrimary,
    Color? brandAccent,
    Color? greenTile,
    Color? blueTile,
    Color? danger,
    Color? dangerSoft,
    Color? dangerLine,
    Color? infoSoft,
    Color? greenSoft,
    Color? skeleton,
    Color? fieldBorder,
    Color? dotInactive,
    Color? paper,
    Color? shadow,
    List<Color>? loaderDots,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      line: line ?? this.line,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      brandAccent: brandAccent ?? this.brandAccent,
      greenTile: greenTile ?? this.greenTile,
      blueTile: blueTile ?? this.blueTile,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerLine: dangerLine ?? this.dangerLine,
      infoSoft: infoSoft ?? this.infoSoft,
      greenSoft: greenSoft ?? this.greenSoft,
      skeleton: skeleton ?? this.skeleton,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      dotInactive: dotInactive ?? this.dotInactive,
      paper: paper ?? this.paper,
      shadow: shadow ?? this.shadow,
      loaderDots: loaderDots ?? this.loaderDots,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      line: l(line, other.line),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      brandAccent: l(brandAccent, other.brandAccent),
      greenTile: l(greenTile, other.greenTile),
      blueTile: l(blueTile, other.blueTile),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      dangerLine: l(dangerLine, other.dangerLine),
      infoSoft: l(infoSoft, other.infoSoft),
      greenSoft: l(greenSoft, other.greenSoft),
      skeleton: l(skeleton, other.skeleton),
      fieldBorder: l(fieldBorder, other.fieldBorder),
      dotInactive: l(dotInactive, other.dotInactive),
      paper: l(paper, other.paper),
      shadow: l(shadow, other.shadow),
      loaderDots: [
        for (var i = 0; i < loaderDots.length; i++)
          l(loaderDots[i], other.loaderDots[i]),
      ],
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}

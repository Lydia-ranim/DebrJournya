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
  static const nightLine = Color(0xFF26302C);
  static const nightInk = Color(0xFFE8E4D8);
  static const nightInk2 = Color(0xFFAEB8B2);
  static const sage = Color(0xFFA3B8A9);
  static const nightMoss = Color(0xFF7F9C88);
  static const nightPine = Color(0xFF3F5847);

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
    required this.success,
    required this.info,
    required this.danger,
    required this.dangerSoft,
    required this.infoSoft,
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
  final Color success;
  final Color info;
  final Color danger;
  final Color dangerSoft;
  final Color infoSoft;

  /// The three splash/loader dots, start to end.
  final List<Color> loaderDots;

  static const light = AppColors(
    background: Palette.cream,
    surface: Colors.white,
    line: Palette.line,
    textPrimary: Palette.ink,
    textSecondary: Palette.ink2,
    primary: Palette.soot,
    onPrimary: Colors.white,
    brandAccent: Palette.moss,
    success: Palette.eucalyptus,
    info: Palette.mist,
    danger: Palette.danger,
    dangerSoft: Palette.dangerSoft,
    infoSoft: Palette.infoSoft,
    loaderDots: [Palette.soot, Palette.moss, Palette.eucalyptus],
  );

  static const dark = AppColors(
    background: Palette.night,
    surface: Palette.nightCard,
    line: Palette.nightLine,
    textPrimary: Palette.nightInk,
    textSecondary: Palette.nightInk2,
    primary: Palette.sage,
    onPrimary: Palette.ink,
    brandAccent: Palette.nightMoss,
    success: Palette.eucalyptus,
    info: Color(0xFF3A4A5A),
    danger: Palette.danger,
    dangerSoft: Color(0xFF3A211C),
    infoSoft: Color(0xFF1B2630),
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
    Color? success,
    Color? info,
    Color? danger,
    Color? dangerSoft,
    Color? infoSoft,
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
      success: success ?? this.success,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      infoSoft: infoSoft ?? this.infoSoft,
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
      success: l(success, other.success),
      info: l(info, other.info),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      infoSoft: l(infoSoft, other.infoSoft),
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

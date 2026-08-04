import 'package:flutter/material.dart';

/// Global light/dark switch. Toggled from Profile → Appearance and listened to
/// by MaterialApp (see main.dart). Default: light.
final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
bool get _dark => darkModeNotifier.value;

/// Design tokens extracted 1:1 from the FC Schalke Club App Figma file.
///
/// Surface / text / border / tinted-background tokens are theme-aware getters
/// (they flip in dark mode). Brand accents, gradients and semantic status
/// colours stay constant across themes so hero cards and CTAs look identical.
class AppColors {
  // ── Brand accents (constant across themes) ──
  static const brandPrimary = Color(0xFF004B9C); // brand/primary/normal
  static const brandDark = Color(0xFF002F63); // brand/primary/dark
  static const brandDarkest = Color(0xFF000D22); // brand/primary/darkest

  // Points / hero gradient + gold / promo gradient (constant)
  static const pointsGradient = [Color(0xFF0055AA), Color(0xFF001B44)];
  static const goldGradient = [Color(0xFFFFB800), Color(0xFFFF8C00)];

  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  // Status accents (constant)
  static const success = Color(0xFF34C759);
  static const gold = Color(0xFFFFB800);
  static const danger = Color(0xFFF04438);

  // ── Theme-aware tokens ──
  // Surfaces
  static Color get surface => _dark ? const Color(0xFF161D28) : const Color(0xFFFFFFFF);
  static Color get surfaceMinimal => _dark ? const Color(0xFF1F2A3A) : const Color(0xFFF2F4F7);
  static Color get surfaceLowContrast => _dark ? const Color(0xFF273347) : const Color(0xFFEAECF0);
  static Color get scaffold => _dark ? const Color(0xFF0D131D) : const Color(0xFFFFFFFF);

  // Borders
  static Color get borderLightest => _dark ? const Color(0xFF273347) : const Color(0xFFEAECF0);

  // Tinted accent backgrounds
  static Color get brandLightest => _dark ? const Color(0xFF16263F) : const Color(0xFFE6F0FF);
  static Color get successBg => _dark ? const Color(0xFF14271C) : const Color(0xFFE6FAEC);
  static Color get dangerBg => _dark ? const Color(0xFF2A1416) : const Color(0xFFFDE7E7);
  static Color get infoBg => _dark ? const Color(0xFF16263F) : const Color(0xFFE5F0FF);

  // Text (dark text on light in light-mode; light text on dark in dark-mode)
  static Color get textDarkest => _dark ? const Color(0xFFFFFFFF) : const Color(0xFF000D22);
  static Color get textDarker => _dark ? const Color(0xFFF2F4F7) : const Color(0xFF1D2939);
  static Color get textDark => _dark ? const Color(0xFFE4E7EC) : const Color(0xFF344054);
  static Color get textNormal => _dark ? const Color(0xFFCDD3DC) : const Color(0xFF475467);
  static Color get textLight => _dark ? const Color(0xFF98A2B3) : const Color(0xFF667085);
  static Color get textLightest => _dark ? const Color(0xFF0D131D) : const Color(0xFFF9FAFB);

  /// Foreground colour for text/icons that sit on a tinted accent background
  /// (brandLightest / gold). Stays readable in both themes.
  static Color get onAccent => _dark ? const Color(0xFFDCE8FF) : brandDarkest;
}

/// Urbanist type scale from the Figma tokens (theme-aware text colours).
class AppText {
  static const _f = 'Urbanist';

  static TextStyle get h1 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 40, height: 46 / 40, color: AppColors.textDarker);
  static TextStyle get h2 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 32, height: 40 / 32, color: AppColors.textDarker);
  static TextStyle get h4 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 28, height: 34 / 28, color: AppColors.textDarker);
  static TextStyle get label1 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 18, height: 24 / 18, color: AppColors.textDarker);
  static TextStyle get label2 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w600, fontSize: 16, height: 22 / 16, color: AppColors.textDarker);
  static TextStyle get body1 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w400, fontSize: 16, height: 24 / 16, color: AppColors.textNormal);
  static TextStyle get body2 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w500, fontSize: 14, height: 20 / 14, color: AppColors.textNormal);
  static TextStyle get body3 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w500, fontSize: 12, height: 16 / 12, color: AppColors.textNormal);
  static TextStyle get body3Regular => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w400, fontSize: 12, height: 16 / 12, color: AppColors.textLight);
  static TextStyle get caption1 => TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w600, fontSize: 10, height: 12 / 10, color: AppColors.textDarker);

  static TextStyle w(TextStyle base, {FontWeight? weight, double? size, Color? color, double? height}) => base.copyWith(
        fontWeight: weight,
        fontSize: size,
        color: color,
        height: height,
      );
}

class AppRadii {
  static const card = 20.0;
  static const tile = 16.0;
  static const chip = 12.0;
  static const pill = 999.0;
  static const nav = 74.0;
  static const field = 12.0;
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final base = ThemeData(useMaterial3: true, brightness: b);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.scaffold,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brandPrimary,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(fontFamily: 'Urbanist'),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

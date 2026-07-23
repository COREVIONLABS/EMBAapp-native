import 'package:flutter/material.dart';

/// Design tokens extracted 1:1 from the FC Schalke Club App Figma file.
class AppColors {
  // Brand (Schalke blue)
  static const brandPrimary = Color(0xFF004B9C); // brand/primary/normal
  static const brandDark = Color(0xFF002F63); // brand/primary/dark
  static const brandDarkest = Color(0xFF000D22); // brand/primary/darkest
  static const brandLightest = Color(0xFFE6F0FF); // brand/primary/lightest

  // Points / hero gradient
  static const pointsGradient = [Color(0xFF0055AA), Color(0xFF001B44)];
  // Gold / promo gradient
  static const goldGradient = [Color(0xFFFFB800), Color(0xFFFF8C00)];

  // Surfaces
  static const surface = Color(0xFFFFFFFF); // surface/primary
  static const surfaceMinimal = Color(0xFFF2F4F7); // surface/minimal
  static const surfaceLowContrast = Color(0xFFEAECF0); // surface/low_contrast
  static const scaffold = Color(0xFFFFFFFF);

  // Borders
  static const borderLightest = Color(0xFFEAECF0);

  // Text
  static const textDarkest = Color(0xFF000D22);
  static const textDarker = Color(0xFF1D2939);
  static const textDark = Color(0xFF344054);
  static const textNormal = Color(0xFF475467);
  static const textLight = Color(0xFF667085);
  static const textLightest = Color(0xFFF9FAFB);

  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  // Semantic
  static const success = Color(0xFF34C759);
  static const successBg = Color(0xFFE6FAEC);
  static const infoBg = Color(0xFFE5F0FF);
  static const gold = Color(0xFFFFB800);
  static const danger = Color(0xFFF04438);
}

/// Urbanist type scale from the Figma tokens.
class AppText {
  static const _f = 'Urbanist';

  static const h1 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 40, height: 46 / 40, color: AppColors.textDarker);
  static const h2 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 32, height: 40 / 32, color: AppColors.textDarker);
  static const h4 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 28, height: 34 / 28, color: AppColors.textDarker);
  static const label1 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w700, fontSize: 18, height: 24 / 18, color: AppColors.textDarker);
  static const label2 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w600, fontSize: 16, height: 22 / 16, color: AppColors.textDarker);
  static const body1 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w400, fontSize: 16, height: 24 / 16, color: AppColors.textNormal);
  static const body2 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w500, fontSize: 14, height: 20 / 14, color: AppColors.textNormal);
  static const body3 = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w500, fontSize: 12, height: 16 / 12, color: AppColors.textNormal);
  static const body3Regular = TextStyle(
      fontFamily: _f, fontWeight: FontWeight.w400, fontSize: 12, height: 16 / 12, color: AppColors.textLight);
  static const caption1 = TextStyle(
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
  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
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

import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0B2E6B);
  static const navyDark = Color(0xFF0A2450);
  static const blue = Color(0xFF1B6BFF);
  static const gold = Color(0xFFF5A623);
  static const green = Color(0xFF2FBF71);
  static const bg = Color(0xFFF4F6FA);
  static const card = Colors.white;
  static const ink = Color(0xFF10203A);
  static const muted = Color(0xFF6B7890);
}

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.navy);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
  );
}

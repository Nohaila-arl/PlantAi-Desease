import 'package:flutter/material.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: Color(0xFF15171E),
    ),
    useMaterial3: true,
    extensions: const [AppColors.dark],
  );

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: Color(0xFFFFFFFF),
    ),
    useMaterial3: true,
    extensions: const [AppColors.light],
  );
}

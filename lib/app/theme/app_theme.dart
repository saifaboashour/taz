import 'package:flutter/material.dart';
import 'package:taz/app/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryAccent,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryAccent,
      onPrimary: AppColors.background,
      secondary: AppColors.secondarySurface,
      onSecondary: AppColors.primaryText,
      error: Colors.red,
      onError: AppColors.primaryText,
      surface: AppColors.card,
      onSurface: AppColors.primaryText,
    ),
  );
}

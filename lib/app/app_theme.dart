import 'package:flutter/material.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_colors.dart';
import 'package:flutter_web_app/core/design_system/tokens/app_typography.dart';

/// Builds the app theme from design tokens.
abstract final class AppTheme {
  /// Material 3 light theme.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      textTheme: const TextTheme(
        titleLarge: AppTypography.title,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
      ),
    );
  }
}

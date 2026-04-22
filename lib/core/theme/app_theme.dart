// ABOUTME: Centralized Material 3 theme definition for the app.
// ABOUTME: Defines color tokens, typography, semantic accident-type colors, and component themes.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';

/// Centralized theme tokens: colors, typography, and component themes.
/// Text styles inherit [MediaQuery.textScalerOf] for accessibility.
class AppTheme {
  AppTheme._();

  // ---------- Deep Emerald palette ----------
  static const Color scaffoldBg = Color(0xFF0A1628);
  static const Color surface = Color(0xFF0E1E35);
  static const Color surfaceElevated = Color(0xFF162540);
  static const Color primary = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF059669);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFE2EDF8);
  static const Color textSecondary = Color(0xFF8AADCC);
  static const Color textMuted = Color(0xFF8AA8C5);
  static const Color outline = Color(0xFF1A3050);
  static const Color outlineVariant = Color(0xFF142A45);
  static const Color error = Color(0xFFF87171);
  static const Color errorContainer = Color(0x1FF87171);

  // ---------- Semantic (accident type) colors ----------
  static const Color semanticFatalities = Color(0xFFEF4444);
  static const Color semanticInjuries = Color(0xFFF97316);
  static const Color semanticMaterialDamage = Color(0xFF3B82F6);


  /// Dark theme (Deep Emerald) applied to the entire app.
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryDark,
      onPrimaryContainer: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceElevated,
      onSurfaceVariant: textSecondary,
      outline: outline,
      outlineVariant: outlineVariant,
      error: error,
      onError: onPrimary,
      errorContainer: errorContainer,
      onErrorContainer: error,
      shadow: Color(0xFF000000),
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
      dividerColor: outline,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: const IconThemeData(color: textPrimary),
        shape: const Border(
          bottom: BorderSide(color: outline, width: 1),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.minTouchTarget,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: textTheme.bodySmall?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodySmall?.copyWith(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        isDense: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: outline),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: surface,
        foregroundColor: primary,
        elevation: 0,
        extendedSizeConstraints: BoxConstraints(minHeight: 56, minWidth: 56),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceElevated,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    const family = 'DMSans';
    const features = [FontFeature.tabularFigures()];
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: family,
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.0,
        letterSpacing: -2.0,
        fontFeatures: features,
      ),
      displayMedium: TextStyle(
        fontFamily: family,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.05,
        letterSpacing: -1.0,
        fontFeatures: features,
      ),
      headlineMedium: TextStyle(
        fontFamily: family,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        fontFeatures: features,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: family,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: family,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: family,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: family,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: family,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 1.5,
      ),
      labelMedium: TextStyle(
        fontFamily: family,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 1.5,
      ),
      labelSmall: TextStyle(
        fontFamily: family,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }


}

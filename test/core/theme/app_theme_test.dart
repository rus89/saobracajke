// ABOUTME: Tests that AppTheme exposes the Deep Emerald dark palette tokens.
// ABOUTME: Guards against accidental color regressions.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

void main() {
  group('AppTheme color tokens', () {
    test('scaffoldBg is Deep Emerald navy', () {
      expect(AppTheme.scaffoldBg, const Color(0xFF0A1628));
    });

    test('surface is elevated emerald navy', () {
      expect(AppTheme.surface, const Color(0xFF0E1E35));
    });

    test('surfaceElevated is brighter navy', () {
      expect(AppTheme.surfaceElevated, const Color(0xFF162540));
    });

    test('primary is emerald 500', () {
      expect(AppTheme.primary, const Color(0xFF10B981));
    });

    test('primaryDark is emerald 600', () {
      expect(AppTheme.primaryDark, const Color(0xFF059669));
    });

    test('textPrimary is near-white navy tint', () {
      expect(AppTheme.textPrimary, const Color(0xFFE2EDF8));
    });

    test('textSecondary is mid-contrast navy tint', () {
      expect(AppTheme.textSecondary, const Color(0xFF8AADCC));
    });

    test('textMuted meets WCAG AA contrast on surface', () {
      expect(AppTheme.textMuted, const Color(0xFF8AA8C5));
    });

    test('outline is navy border', () {
      expect(AppTheme.outline, const Color(0xFF1A3050));
    });

    test('outlineVariant is subtler navy border', () {
      expect(AppTheme.outlineVariant, const Color(0xFF142A45));
    });

    test('semantic colors preserved', () {
      expect(AppTheme.semanticFatalities, const Color(0xFFEF4444));
      expect(AppTheme.semanticInjuries, const Color(0xFFF97316));
      expect(AppTheme.semanticMaterialDamage, const Color(0xFF3B82F6));
    });
  });

  group('AppTheme typography', () {
    test('uses DMSans font family on displayLarge', () {
      final style = AppTheme.dark.textTheme.displayLarge;
      expect(style?.fontFamily, 'DMSans');
    });

    test('displayLarge is 48px weight 800', () {
      final style = AppTheme.dark.textTheme.displayLarge;
      expect(style?.fontSize, 48);
      expect(style?.fontWeight, FontWeight.w800);
    });

    test('labelSmall is 10px weight 600 with 1.5px tracking', () {
      final style = AppTheme.dark.textTheme.labelSmall;
      expect(style?.fontSize, 10);
      expect(style?.fontWeight, FontWeight.w600);
      expect(style?.letterSpacing, 1.5);
    });

    test('bodyMedium uses textPrimary color', () {
      final style = AppTheme.dark.textTheme.bodyMedium;
      expect(style?.color, AppTheme.textPrimary);
    });

    test('bodyLarge uses textPrimary color', () {
      final style = AppTheme.dark.textTheme.bodyLarge;
      expect(style?.color, AppTheme.textPrimary);
    });
  });

  group('AppTheme component themes', () {
    test('is dark brightness', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
    });

    test('app bar uses scaffoldBg background', () {
      expect(AppTheme.dark.appBarTheme.backgroundColor, AppTheme.scaffoldBg);
    });

    test('card theme uses surface color', () {
      expect(AppTheme.dark.cardTheme.color, AppTheme.surface);
    });

    test('bottom navigation uses surface background', () {
      expect(
        AppTheme.dark.bottomNavigationBarTheme.backgroundColor,
        AppTheme.surface,
      );
    });

    test('bottom sheet uses surfaceElevated background', () {
      expect(
        AppTheme.dark.bottomSheetTheme.backgroundColor,
        AppTheme.surfaceElevated,
      );
    });

    test('floating action button has zero elevation', () {
      expect(AppTheme.dark.floatingActionButtonTheme.elevation, 0);
    });

    test('dialog uses surfaceElevated background', () {
      expect(
        AppTheme.dark.dialogTheme.backgroundColor,
        AppTheme.surfaceElevated,
      );
    });

    test('scaffold background uses scaffoldBg token', () {
      expect(AppTheme.dark.scaffoldBackgroundColor, AppTheme.scaffoldBg);
    });
  });
}

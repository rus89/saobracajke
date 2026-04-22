// ABOUTME: Frosted-glass floating action button used for map zoom and recenter controls.
// ABOUTME: Deduplicates the surface-tinted FAB decoration used across multiple map actions.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

class GlassyFab extends StatelessWidget {
  const GlassyFab({
    super.key,
    required this.heroTag,
    required this.semanticLabel,
    required this.icon,
    required this.onPressed,
  });

  final String heroTag;
  final String semanticLabel;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: AppTheme.surface.withValues(alpha: 0.92),
        foregroundColor: AppTheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppTheme.outline),
        ),
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}

// ABOUTME: Frosted-glass legend overlay describing accident-type marker colors.
// ABOUTME: Used on the map screen to associate each marker color with its label.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/domain/accident_types.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Map legend: accident types by color',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.92),
              border: Border.all(color: AppTheme.outline),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEGENDA',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                _LegendItem(
                  color: AccidentTypes.markerColor(AccidentTypes.fatalities),
                  label: AccidentTypes.displayLabel(AccidentTypes.fatalities),
                ),
                const SizedBox(height: AppSpacing.xs),
                _LegendItem(
                  color: AccidentTypes.markerColor(AccidentTypes.injuries),
                  label: AccidentTypes.displayLabel(AccidentTypes.injuries),
                ),
                const SizedBox(height: AppSpacing.xs),
                _LegendItem(
                  color:
                      AccidentTypes.markerColor(AccidentTypes.materialDamage),
                  label:
                      AccidentTypes.displayLabel(AccidentTypes.materialDamage),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

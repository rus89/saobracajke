// ABOUTME: Polarity-aware pill badge for year-over-year deltas.
// ABOUTME: Red when worse (delta > 0), emerald when better, muted when unchanged.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

class DeltaBadge extends StatelessWidget {
  const DeltaBadge({
    super.key,
    required this.delta,
    this.trailing,
    this.showArrow = true,
  });

  final int delta;
  final String? trailing;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color;
    final IconData? arrow;
    final String semanticLabel;
    if (delta > 0) {
      color = AppTheme.error;
      arrow = Icons.arrow_upward;
      semanticLabel = 'Porast za $delta u odnosu na prošlu godinu';
    } else if (delta < 0) {
      color = AppTheme.primary;
      arrow = Icons.arrow_downward;
      semanticLabel = 'Pad za ${-delta} u odnosu na prošlu godinu';
    } else {
      color = AppTheme.textSecondary;
      arrow = null;
      semanticLabel = 'Bez promene u odnosu na prošlu godinu';
    }
    final bg = color.withValues(alpha: 0.12);
    final sign = delta > 0 ? '+' : '';

    return Semantics(
      label: semanticLabel,
      container: true,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showArrow && arrow != null) ...[
              Icon(arrow, size: 14, color: color),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              '$sign$delta',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                trailing!,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

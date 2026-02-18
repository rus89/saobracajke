import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

class _MiniStatArgs {
  final String label;
  final int count;
  final int delta;
  final Color color;
  final IconData icon;
  _MiniStatArgs({
    required this.label,
    required this.count,
    required this.delta,
    required this.color,
    required this.icon,
  });
}

class SectionOneHeader extends StatelessWidget {
  final int totalAccidents;
  final int delta;
  final int fatalities;
  final int fatalitiesDelta;
  final int injuries;
  final int injuriesDelta;
  final int materialDamageAccidents;
  final int materialDamageAccidentsDelta;

  const SectionOneHeader({
    super.key,
    required this.totalAccidents,
    required this.delta,
    required this.fatalities,
    required this.fatalitiesDelta,
    required this.injuries,
    required this.injuriesDelta,
    required this.materialDamageAccidents,
    required this.materialDamageAccidentsDelta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isImprovement = delta <= 0;
    final trendColor = isImprovement
        ? AppTheme.primaryGreen
        : theme.colorScheme.error;
    final trendBg = isImprovement
        ? AppTheme.primaryGreen.withValues(alpha: 0.12)
        : theme.colorScheme.errorContainer;
    final sign = delta > 0 ? '+' : '';

    return Semantics(
      label:
          'Key metrics: $totalAccidents total accidents, trend $delta vs last year. Injuries: $injuries, Fatalities: $fatalities, Material damage: $materialDamageAccidents',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'UKUPNO NESREĆA',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1.2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    NumberFormat('#,###').format(totalAccidents),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: trendBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isImprovement
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 18,
                          color: trendColor,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '$sign$delta',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: trendColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'vs prošle godine',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: trendColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                const breakpoint = 600.0;
                final narrow = constraints.maxWidth < breakpoint;
                final miniStats = [
                  _MiniStatArgs(
                    label: 'POVREĐENI',
                    count: injuries,
                    delta: injuriesDelta,
                    color: Colors.orange,
                    icon: Icons.personal_injury,
                  ),
                  _MiniStatArgs(
                    label: 'POGINULI',
                    count: fatalities,
                    delta: fatalitiesDelta,
                    color: Colors.red,
                    icon: Icons.heart_broken,
                  ),
                  _MiniStatArgs(
                    label: 'SA MATERIJALNOM ŠTETOM',
                    count: materialDamageAccidents,
                    delta: materialDamageAccidentsDelta,
                    color: Colors.blue,
                    icon: Icons.build,
                  ),
                ];
                if (narrow) {
                  return Column(
                    children: [
                      for (var i = 0; i < miniStats.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.md),
                        _buildMiniStat(
                          context: context,
                          label: miniStats[i].label,
                          count: miniStats[i].count,
                          delta: miniStats[i].delta,
                          color: miniStats[i].color,
                          icon: miniStats[i].icon,
                        ),
                      ],
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        context: context,
                        label: miniStats[0].label,
                        count: miniStats[0].count,
                        delta: miniStats[0].delta,
                        color: miniStats[0].color,
                        icon: miniStats[0].icon,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildMiniStat(
                        context: context,
                        label: miniStats[1].label,
                        count: miniStats[1].count,
                        delta: miniStats[1].delta,
                        color: miniStats[1].color,
                        icon: miniStats[1].icon,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildMiniStat(
                        context: context,
                        label: miniStats[2].label,
                        count: miniStats[2].count,
                        delta: miniStats[2].delta,
                        color: miniStats[2].color,
                        icon: miniStats[2].icon,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required BuildContext context,
    required String label,
    required int count,
    required int delta,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isUp = delta > 0;
    final deltaColor = isUp ? theme.colorScheme.error : AppTheme.primaryGreen;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isUp ? '+' : ''}$delta',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: deltaColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            NumberFormat('#,###').format(count),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

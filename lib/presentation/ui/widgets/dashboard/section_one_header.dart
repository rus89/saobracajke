// ABOUTME: Dashboard section 1 body: hero KPI card plus mini stats for injuries/fatalities/material damage.
// ABOUTME: Consumes DeltaBadge for year-over-year indicators and shows three-column grid of metrics.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/presentation/ui/widgets/delta_badge.dart';

class SectionOneHeader extends StatelessWidget {
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

  final int totalAccidents;
  final int delta;
  final int fatalities;
  final int fatalitiesDelta;
  final int injuries;
  final int injuriesDelta;
  final int materialDamageAccidents;
  final int materialDamageAccidentsDelta;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Key metrics: $totalAccidents total accidents, trend $delta vs last year. Injuries: $injuries, Fatalities: $fatalities, Material damage: $materialDamageAccidents',
      child: Column(
        children: [
          _HeroCard(total: totalAccidents, delta: delta),
          const SizedBox(height: AppSpacing.lg),
          _MiniGrid(
            injuries: injuries,
            injuriesDelta: injuriesDelta,
            fatalities: fatalities,
            fatalitiesDelta: fatalitiesDelta,
            materialDamage: materialDamageAccidents,
            materialDamageDelta: materialDamageAccidentsDelta,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.total, required this.delta});

  final int total;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UKUPNO NESREĆA',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  NumberFormat('#,###').format(total),
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                DeltaBadge(
                  delta: delta,
                  trailing: 'vs prošle godine',
                  showArrow: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  const _MiniGrid({
    required this.injuries,
    required this.injuriesDelta,
    required this.fatalities,
    required this.fatalitiesDelta,
    required this.materialDamage,
    required this.materialDamageDelta,
  });

  final int injuries;
  final int injuriesDelta;
  final int fatalities;
  final int fatalitiesDelta;
  final int materialDamage;
  final int materialDamageDelta;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        final cards = [
          _MiniStat(
            label: 'POVREĐENI',
            count: injuries,
            delta: injuriesDelta,
            color: AppTheme.semanticInjuries,
            icon: Icons.personal_injury,
          ),
          _MiniStat(
            label: 'POGINULI',
            count: fatalities,
            delta: fatalitiesDelta,
            color: AppTheme.semanticFatalities,
            icon: Icons.heart_broken,
          ),
          _MiniStat(
            label: 'MAT. ŠTETA',
            count: materialDamage,
            delta: materialDamageDelta,
            color: AppTheme.semanticMaterialDamage,
            icon: Icons.build,
          ),
        ];
        if (narrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                cards[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.count,
    required this.delta,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final int delta;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            NumberFormat('#,###').format(count),
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          DeltaBadge(delta: delta),
        ],
      ),
    );
  }
}

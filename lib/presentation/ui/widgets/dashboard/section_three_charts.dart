import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/presentation/ui/widgets/empty_state.dart';

class SectionThreeTemporal extends StatefulWidget {
  const SectionThreeTemporal({
    super.key,
    required this.seasonCounts,
    required this.weekendCounts,
    required this.timeOfDayCounts,
  });

  final Map<String, int> seasonCounts;
  final Map<String, int> weekendCounts;
  final Map<String, int> timeOfDayCounts;

  @override
  State<SectionThreeTemporal> createState() => _SectionThreeTemporalState();
}

class _SectionThreeTemporalState extends State<SectionThreeTemporal> {
  static const _narrowBreakpoint = 500.0;

  int _seasonTouched = -1;
  int _weekendTouched = -1;
  int _timeTouched = -1;

  @override
  void didUpdateWidget(covariant SectionThreeTemporal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seasonTouched = -1;
    _weekendTouched = -1;
    _timeTouched = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Temporal distribution: by season, weekday vs weekend, time of day',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildSeasonChart(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildWeekendChart(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildTimeOfDayChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonChart(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < _narrowBreakpoint;
    final colors = [
      AppTheme.primaryGreen.withValues(alpha: 0.8),
      AppTheme.semanticInjuries.withValues(alpha: 0.9),
      AppTheme.semanticFatalities.withValues(alpha: 0.9),
      AppTheme.semanticMaterialDamage.withValues(alpha: 0.9),
    ];

    final total = widget.seasonCounts.values.fold(0, (sum, val) => sum + val);
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nesreće po godišnjim dobima',
              style: theme.textTheme.titleMedium,
            ),
            const EmptyState(
              icon: Icons.pie_chart_outline,
              title: 'Nema podataka',
              subtitle: 'Nema nesreća za prikazivanje u ovom periodu.',
            ),
          ],
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    widget.seasonCounts.forEach((season, count) {
      final percentage = (count / total * 100).toStringAsFixed(1);
      final isTouched = _seasonTouched == colorIndex;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: '$percentage%',
          radius: isTouched ? 110 : 100,
          titleStyle:
              theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.surface,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      );
      colorIndex++;
    });

    final pieData = PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                response?.touchedSection == null) {
              _seasonTouched = -1;
              return;
            }
            _seasonTouched = response!.touchedSection!.touchedSectionIndex;
          });
        },
      ),
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 0,
      borderData: FlBorderData(show: false),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nesreće po godišnjim dobima',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          narrow
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 160,
                      child: PieChart(pieData),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...widget.seasonCounts.entries.toList().asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final season = entry.value.key;
                      final count = entry.value.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    season,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$count nesreća',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                )
              : SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(pieData),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.seasonCounts.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final season = entry.value.key;
                                final count = entry.value.value;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: colors[index % colors.length],
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              season,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              '$count nesreća',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWeekendChart(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < _narrowBreakpoint;
    final colors = [
      AppTheme.semanticMaterialDamage,
      AppTheme.primaryGreen,
    ];

    final total = widget.weekendCounts.values.fold(0, (sum, val) => sum + val);
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nesreće: Radni dani vs Vikend',
              style: theme.textTheme.titleMedium,
            ),
            const EmptyState(
              icon: Icons.pie_chart_outline,
              title: 'Nema podataka',
              subtitle: 'Nema nesreća za prikazivanje u ovom periodu.',
            ),
          ],
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    // Track section index separately because we skip entries with count == 0.
    int sectionIndex = 0;

    // Ensure consistent order: Weekday first, Weekend second
    final orderedKeys = ['Radni dan', 'Vikend'];
    // Map from colorIndex to sectionIndex for touch matching
    final colorForSection = <int, int>{};

    for (int colorIndex = 0; colorIndex < orderedKeys.length; colorIndex++) {
      final key = orderedKeys[colorIndex];
      final count = widget.weekendCounts[key] ?? 0;
      if (count > 0) {
        final percentage = (count / total * 100).toStringAsFixed(1);
        final isTouched = _weekendTouched == sectionIndex;
        colorForSection[colorIndex] = sectionIndex;
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex],
            value: count.toDouble(),
            title: '$percentage%',
            radius: isTouched ? 110 : 100,
            titleStyle:
                theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.surface,
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
        );
        sectionIndex++;
      }
    }

    final pieData = PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                response?.touchedSection == null) {
              _weekendTouched = -1;
              return;
            }
            _weekendTouched = response!.touchedSection!.touchedSectionIndex;
          });
        },
      ),
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 0,
      borderData: FlBorderData(show: false),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nesreće: Radni dani vs Vikend',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),
          narrow
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 160,
                      child: PieChart(pieData),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...orderedKeys.asMap().entries.map((entry) {
                      final index = entry.key;
                      final key = entry.value;
                      final count = widget.weekendCounts[key] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    key,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$count nesreća',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                )
              : SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(pieData),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: orderedKeys.asMap().entries.map((entry) {
                            final index = entry.key;
                            final key = entry.value;
                            final count = widget.weekendCounts[key] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: colors[index],
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          key,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          '$count nesreća',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayChart(BuildContext context) {
    final theme = Theme.of(context);
    final narrow = MediaQuery.sizeOf(context).width < _narrowBreakpoint;
    final colors = [
      AppTheme.primaryGreen,
      AppTheme.semanticInjuries,
      AppTheme.semanticFatalities,
      AppTheme.semanticMaterialDamage,
    ];

    final total =
        widget.timeOfDayCounts.values.fold(0, (sum, val) => sum + val);
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nesreće po delu dana',
              style: theme.textTheme.titleMedium,
            ),
            const EmptyState(
              icon: Icons.pie_chart_outline,
              title: 'Nema podataka',
              subtitle: 'Nema nesreća za prikazivanje u ovom periodu.',
            ),
          ],
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    widget.timeOfDayCounts.forEach((timeOfDay, count) {
      final percentage = (count / total * 100).toStringAsFixed(1);
      final isTouched = _timeTouched == colorIndex;
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: '$percentage%',
          radius: isTouched ? 110 : 100,
          titleStyle:
              theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.surface,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      );
      colorIndex++;
    });

    final pieData = PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                response?.touchedSection == null) {
              _timeTouched = -1;
              return;
            }
            _timeTouched = response!.touchedSection!.touchedSectionIndex;
          });
        },
      ),
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 0,
      borderData: FlBorderData(show: false),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nesreće po delu dana', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xxl),
          narrow
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 160,
                      child: PieChart(pieData),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...widget.timeOfDayCounts.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((
                      entry,
                    ) {
                      final index = entry.key;
                      final timeOfDay = entry.value.key;
                      final count = entry.value.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeOfDay,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$count nesreća',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                )
              : SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(pieData),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.timeOfDayCounts.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final timeOfDay = entry.value.key;
                                final count = entry.value.value;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: colors[index % colors.length],
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              timeOfDay,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Text(
                                              '$count nesreća',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

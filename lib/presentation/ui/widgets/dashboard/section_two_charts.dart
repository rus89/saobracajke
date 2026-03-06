import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/presentation/ui/widgets/empty_state.dart';

class SectionTwoCharts extends StatelessWidget {
  const SectionTwoCharts({
    super.key,
    required this.monthlyAccidents,
    required this.typeMonthlyAccidents,
    required this.stationAccidents,
  });

  final Map<int, int> monthlyAccidents;
  final Map<String, Map<int, int>> typeMonthlyAccidents;
  final Map<String, int> stationAccidents;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun',
    'Jul', 'Avg', 'Sep', 'Okt', 'Nov', 'Dec',
  ];

  static const _monthsFull = [
    'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Jun',
    'Jul', 'Avgust', 'Septembar', 'Oktobar', 'Novembar', 'Decembar',
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Charts: monthly accidents, accidents by type per month, top police stations',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildMonthlyChart(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildTypeMonthlyChart(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildStationChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 400;
    final chartHeight = narrow ? 220.0 : 300.0;
    final spots = <FlSpot>[];
    for (int i = 1; i <= 12; i++) {
      spots.add(FlSpot(i.toDouble(), (monthlyAccidents[i] ?? 0).toDouble()));
    }

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
          Text('Nesreće po mesecima', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                    getTooltipItems: (spots) => spots.map((s) {
                      final monthIndex = s.x.toInt();
                      if (monthIndex >= 1 && monthIndex <= 12) {
                        return LineTooltipItem(
                          '${_monthsFull[monthIndex - 1]}: ${s.y.toInt()}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      return LineTooltipItem(
                        '${s.y.toInt()}',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 1 && value.toInt() <= 12) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _months[value.toInt() - 1],
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: theme.colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: theme.colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeMonthlyChart(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 400;
    final chartHeight = narrow ? 220.0 : 300.0;
    final colors = [
      AppTheme.semanticFatalities,
      AppTheme.semanticInjuries,
      AppTheme.semanticMaterialDamage,
    ];

    int colorIndex = 0;
    final lines = <LineChartBarData>[];

    typeMonthlyAccidents.forEach((typeName, monthData) {
      final spots = <FlSpot>[];
      for (int i = 1; i <= 12; i++) {
        spots.add(FlSpot(i.toDouble(), (monthData[i] ?? 0).toDouble()));
      }
      final color = colors[colorIndex % colors.length];
      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 1,
                strokeColor: theme.colorScheme.surface,
              );
            },
          ),
        ),
      );
      colorIndex++;
    });

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
            'Nesreće po tipu po mesecima',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                    getTooltipItems: (spots) {
                      final typeKeys = typeMonthlyAccidents.keys.toList();
                      return spots.map((s) {
                        final typeName = typeKeys[s.barIndex];
                        return LineTooltipItem(
                          '$typeName: ${s.y.toInt()}',
                          TextStyle(
                            color: colors[s.barIndex % colors.length],
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 1 && value.toInt() <= 12) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _months[value.toInt() - 1],
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                lineBarsData: lines,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            children: typeMonthlyAccidents.keys.toList().asMap().entries.map((
              entry,
            ) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(entry.value, style: theme.textTheme.bodyMedium),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStationChart(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 400;
    final chartHeight = narrow ? 280.0 : 400.0;
    final bottomReserved = narrow ? 56.0 : 80.0;
    final sortedStations = stationAccidents.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topStations = sortedStations.take(10).toList();

    if (topStations.isEmpty) {
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
              'Top 10 policijskih stanica po broju nesreća',
              style: theme.textTheme.titleMedium,
            ),
            const EmptyState(
              icon: Icons.bar_chart,
              title: 'Nema podataka o stanicama',
              subtitle: 'Promenite filtere da biste videli podatke.',
            ),
          ],
        ),
      );
    }

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
            'Top 10 policijskih stanica po broju nesreća',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: chartHeight,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final stationName = topStations[group.x].key;
                      final count = rod.toY.toInt();
                      return BarTooltipItem(
                        '$stationName\n$count nesreća',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: bottomReserved,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < topStations.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: Text(
                                topStations[index].key,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                barGroups: topStations.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: AppTheme.primaryGreenDark,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

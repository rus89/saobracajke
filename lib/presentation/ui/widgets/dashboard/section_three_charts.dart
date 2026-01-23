import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SectionThreeTemporal extends StatelessWidget {
  final Map<String, int> seasonCounts;
  final Map<String, int> weekendCounts;
  final Map<String, int> timeOfDayCounts;

  const SectionThreeTemporal({
    super.key,
    required this.seasonCounts,
    required this.weekendCounts,
    required this.timeOfDayCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chart 1: Seasons
          _buildSeasonChart(),
          const SizedBox(height: 24),
          // Chart 2: Weekend vs Weekday
          _buildWeekendChart(),
          const SizedBox(height: 24),
          // Chart 3: Time of Day
          _buildTimeOfDayChart(),
        ],
      ),
    );
  }

  Widget _buildSeasonChart() {
    final colors = [
      Colors.green.shade400, // Proljeće (Spring)
      Colors.orange.shade400, // Ljeto (Summer)
      Colors.brown.shade400, // Jesen (Autumn)
      Colors.blue.shade400, // Zima (Winter)
    ];

    final total = seasonCounts.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    seasonCounts.forEach((season, count) {
      final percentage = (count / total * 100).toStringAsFixed(1);
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: '$percentage%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nesreće po godišnjim dobima',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: seasonCounts.entries.toList().asMap().entries.map(
                      (entry) {
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
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      season,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$count nesreća',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendChart() {
    final colors = [
      Colors.blue.shade500, // Radni dan (Weekday)
      Colors.purple.shade400, // Vikend (Weekend)
    ];

    final total = weekendCounts.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    // Ensure consistent order: Weekday first, Weekend second
    final orderedKeys = ['Radni dan', 'Vikend'];
    for (var key in orderedKeys) {
      final count = weekendCounts[key] ?? 0;
      if (count > 0) {
        final percentage = (count / total * 100).toStringAsFixed(1);
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex],
            value: count.toDouble(),
            title: '$percentage%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      colorIndex++;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nesreće: Radni dani vs Vikend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: orderedKeys.asMap().entries.map((entry) {
                      final index = entry.key;
                      final key = entry.value;
                      final count = weekendCounts[key] ?? 0;
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    key,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '$count nesreća',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
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

  Widget _buildTimeOfDayChart() {
    final colors = [
      Colors.indigo.shade900, // Noć (Night)
      Colors.amber.shade400, // Jutro (Morning)
      Colors.orange.shade500, // Popodne (Afternoon)
      Colors.deepPurple.shade400, // Veče (Evening)
    ];

    final total = timeOfDayCounts.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    timeOfDayCounts.forEach((timeOfDay, count) {
      final percentage = (count / total * 100).toStringAsFixed(1);
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          title: '$percentage%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nesreće po delu dana',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: timeOfDayCounts.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        timeOfDay,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$count nesreća',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
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

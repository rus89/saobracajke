import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SectionTwoCharts extends StatelessWidget {
  final Map<int, int> monthlyAccidents;
  final Map<String, Map<int, int>> typeMonthlyAccidents;
  final Map<String, int> stationAccidents;

  const SectionTwoCharts({
    super.key,
    required this.monthlyAccidents,
    required this.typeMonthlyAccidents,
    required this.stationAccidents,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Chart 1: Monthly Accidents
          _buildMonthlyChart(),
          const SizedBox(height: 24),
          // Chart 2: Type per Month
          _buildTypeMonthlyChart(),
          const SizedBox(height: 24),
          // Chart 3: Station Accidents
          if (stationAccidents.isNotEmpty) _buildStationChart(),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final spots = <FlSpot>[];
    for (int i = 1; i <= 12; i++) {
      spots.add(FlSpot(i.toDouble(), (monthlyAccidents[i] ?? 0).toDouble()));
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
            'Nesreće po mesecima',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'Maj',
                          'Jun',
                          'Jul',
                          'Avg',
                          'Sep',
                          'Okt',
                          'Nov',
                          'Dec',
                        ];
                        if (value.toInt() >= 1 && value.toInt() <= 12) {
                          return Text(months[value.toInt() - 1]);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue.shade600,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeMonthlyChart() {
    final colors = [
      Colors.red.shade600,
      Colors.orange.shade600,
      Colors.green.shade600,
    ];

    int colorIndex = 0;
    final lines = <LineChartBarData>[];

    typeMonthlyAccidents.forEach((typeName, monthData) {
      final spots = <FlSpot>[];
      for (int i = 1; i <= 12; i++) {
        spots.add(FlSpot(i.toDouble(), (monthData[i] ?? 0).toDouble()));
      }

      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colors[colorIndex % colors.length],
          barWidth: 2,
          dotData: FlDotData(show: false),
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
            'Nesreće po tipu po mesecima',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'Maj',
                          'Jun',
                          'Jul',
                          'Avg',
                          'Sep',
                          'Okt',
                          'Nov',
                          'Dec',
                        ];
                        if (value.toInt() >= 1 && value.toInt() <= 12) {
                          return Text(months[value.toInt() - 1]);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                lineBarsData: lines,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            children: typeMonthlyAccidents.keys.toList().asMap().entries.map((
              entry,
            ) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: colors[entry.key % colors.length],
                  ),
                  const SizedBox(width: 8),
                  Text(entry.value),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStationChart() {
    final sortedStations = stationAccidents.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedStations.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedStations[i].value.toDouble()));
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
            'Nesreće po policijskoj stanici',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedStations.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                sortedStations[index].key,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.purple.shade600,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

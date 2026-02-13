import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_one_header.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_three_charts.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_two_charts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saobraćajne Nezgode - Pregled'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Year & Department Filter
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Year Dropdown
                        DropdownButtonFormField<int>(
                          initialValue: state.selectedYear,
                          decoration: InputDecoration(
                            labelText: 'Izaberite godinu',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: state.availableYears.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (year) {
                            if (year != null) {
                              ref
                                  .read(dashboardProvider.notifier)
                                  .setYear(year);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Department Dropdown
                        DropdownButtonFormField<String?>(
                          initialValue: state.selectedDept,
                          decoration: InputDecoration(
                            labelText: 'Izaberite policijsku upravu',
                            prefixIcon: const Icon(Icons.location_city),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Sve policijske uprave'),
                            ),
                            ...state.departments.map(
                              (dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              ),
                            ),
                          ],
                          onChanged: (dept) {
                            ref
                                .read(dashboardProvider.notifier)
                                .setDepartment(dept);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Section 1: Key Metrics
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Sekcija 1: Ključni pokazatelji',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SectionOneHeader(
                      totalAccidents: state.totalAccidents,
                      delta: state.deltaAccidents,
                      fatalities: state.fatalitiesCount,
                      fatalitiesDelta: 0,
                      injuries: state.injuriesCount,
                      injuriesDelta: 0,
                      materialDamageAccidents: state.materialDamageCount,
                      materialDamageAccidentsDelta: 0,
                    ),
                  ),
                  // Placeholder for Section 2
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Sekcija 2: Trendovi i Analize',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SectionTwoCharts(
                      monthlyAccidents: state.monthlyAccidents,
                      typeMonthlyAccidents: state.typeMonthlyAccidents,
                      stationAccidents: state.stationAccidents,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Sekcija 3: Vremenska Distribucija',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SectionThreeTemporal(
                      seasonCounts: state.seasonCounts,
                      weekendCounts: state.weekendCounts,
                      timeOfDayCounts: state.timeOfDayCounts,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

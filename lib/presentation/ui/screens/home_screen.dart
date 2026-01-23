import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saobracajke/presentation/logic/traffic_provider.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_one_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trafficProvider);

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
                              ref.read(trafficProvider.notifier).setYear(year);
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
                                .read(trafficProvider.notifier)
                                .setDepartment(dept);
                          },
                        ),
                      ],
                    ),
                  ),
                  // Section 1: Key Metrics
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
                  // Placeholder for Section 2 & 3
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Section 2 & 3 coming soon...'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

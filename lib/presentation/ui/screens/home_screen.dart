import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saobracajke/presentation/logic/traffic_provider.dart';
import 'package:saobracajke/presentation/ui/widgets/accident_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the state
    final state = ref.watch(trafficProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saobraćajne Nezgode')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: DropdownButtonFormField<String?>(
                    initialValue: state.selectedDept,
                    decoration: const InputDecoration(
                      labelText: 'Izaberite policijsku upravu',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sve policijske uprave'),
                      ),
                      ...state.departments.map(
                        (dept) =>
                            DropdownMenuItem(value: dept, child: Text(dept)),
                      ),
                    ],
                    onChanged: (val) {
                      ref.read(trafficProvider.notifier).setDepartment(val);
                    },
                  ),
                ),
                // Accident List
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.accidents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nema podataka',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.accidents.length,
                          itemBuilder: (ctx, index) =>
                              AccidentCard(accident: state.accidents[index]),
                        ),
                ),
              ],
            ),
    );
  }
}

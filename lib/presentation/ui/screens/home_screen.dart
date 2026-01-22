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
      body: state.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Your Filter Dropdown
                DropdownButton(
                  value: state.selectedDept,
                  onChanged: (val) {
                    // 2. Update logic
                    ref
                        .read(trafficProvider.notifier)
                        .setDepartment(val as String?);
                  },
                  items: [],
                ),
                // Your List
                Expanded(
                  child: ListView.builder(
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

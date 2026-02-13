import 'package:flutter/material.dart';

/// Reusable year and department filter used by [HomeScreen] and [MapScreen].
/// Drives the same dashboard filter state via callbacks.
class YearDepartmentFilter extends StatelessWidget {
  const YearDepartmentFilter({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.selectedDept,
    required this.departments,
    required this.onYearChanged,
    required this.onDepartmentChanged,
    this.compact = false,
  });

  final int? selectedYear;
  final List<int> availableYears;
  final String? selectedDept;
  final List<String> departments;
  final ValueChanged<int?>? onYearChanged;
  final ValueChanged<String?>? onDepartmentChanged;

  /// When true, uses denser layout (e.g. for map overlay card).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spacing = compact ? 8.0 : 12.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<int>(
          initialValue: selectedYear,
          decoration: InputDecoration(
            labelText: 'Izaberite godinu',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 4 : 8),
            ),
            filled: !compact,
            fillColor: compact ? null : Colors.white,
            isDense: compact,
          ),
          items: availableYears
              .map(
                (year) =>
                    DropdownMenuItem(value: year, child: Text(year.toString())),
              )
              .toList(),
          onChanged: onYearChanged,
        ),
        SizedBox(height: spacing),
        DropdownButtonFormField<String?>(
          initialValue: selectedDept,
          decoration: InputDecoration(
            labelText: 'Izaberite policijsku upravu',
            prefixIcon: const Icon(Icons.location_city),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 4 : 8),
            ),
            filled: !compact,
            fillColor: compact ? null : Colors.white,
            isDense: compact,
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Sve policijske uprave'),
            ),
            ...departments.map(
              (dept) =>
                  DropdownMenuItem<String?>(value: dept, child: Text(dept)),
            ),
          ],
          onChanged: onDepartmentChanged,
        ),
      ],
    );
  }
}

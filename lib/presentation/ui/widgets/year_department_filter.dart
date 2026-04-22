// ABOUTME: Reusable filter widget with year and police department dropdown selectors.
// ABOUTME: Chip-style presentation on both home screen and map overlay.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

class YearDepartmentFilter extends StatelessWidget {
  const YearDepartmentFilter({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.selectedDept,
    required this.departments,
    required this.onYearChanged,
    required this.onDepartmentChanged,
  });

  final int? selectedYear;
  final List<int> availableYears;
  final String? selectedDept;
  final List<String> departments;
  final ValueChanged<int?>? onYearChanged;
  final ValueChanged<String?>? onDepartmentChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filter by year and police department',
      child: Row(
        children: [
          Expanded(
            child: _Chip<int>(
              value: selectedYear,
              items: availableYears
                  .map(
                    (y) => DropdownMenuItem(value: y, child: Text(y.toString())),
                  )
                  .toList(),
              hint: 'Godina',
              onChanged: onYearChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Chip<String?>(
              value: selectedDept,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sve uprave'),
                ),
                ...departments.map(
                  (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
                ),
              ],
              hint: 'Uprava',
              onChanged: onDepartmentChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip<T> extends StatelessWidget {
  const _Chip({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.outline),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            hint: Text(
              hint,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            dropdownColor: AppTheme.surfaceElevated,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textMuted,
            ),
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

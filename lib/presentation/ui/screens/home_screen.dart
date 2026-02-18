import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_one_header.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_three_charts.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_two_charts.dart';
import 'package:saobracajke/presentation/ui/widgets/year_department_filter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    final notifier = ref.read(dashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Saobraćajne Nezgode - Pregled')),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.errorMessage != null)
              MaterialBanner(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.errorContainer,
                leading: Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                actions: [
                  TextButton(
                    onPressed: () => notifier.retry(),
                    child: Text(
                      'Pokušaj ponovo',
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: state.isLoading
                ? Semantics(
                    label: 'Loading dashboard data',
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: 'Filter by year and police department',
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                      ),
                      child: YearDepartmentFilter(
                        selectedYear: state.selectedYear,
                        availableYears: state.availableYears,
                        selectedDept: state.selectedDept,
                        departments: state.departments,
                        onYearChanged: (year) {
                          if (year != null) {
                            ref.read(dashboardProvider.notifier).setYear(year);
                          }
                        },
                        onDepartmentChanged: (dept) {
                          ref
                              .read(dashboardProvider.notifier)
                              .setDepartment(dept);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: Text(
                      'Sekcija 1: Ključni pokazatelji',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SectionOneHeader(
                      totalAccidents: state.totalAccidents,
                      delta: state.deltaAccidents,
                      fatalities: state.fatalitiesCount,
                      fatalitiesDelta: state.fatalitiesDelta,
                      injuries: state.injuriesCount,
                      injuriesDelta: state.injuriesDelta,
                      materialDamageAccidents: state.materialDamageCount,
                      materialDamageAccidentsDelta: state.materialDamageDelta,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: Text(
                      'Sekcija 2: Trendovi i Analize',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SectionTwoCharts(
                      monthlyAccidents: state.monthlyAccidents,
                      typeMonthlyAccidents: state.typeMonthlyAccidents,
                      stationAccidents: state.stationAccidents,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: Text(
                      'Sekcija 3: Vremenska Distribucija',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SectionThreeTemporal(
                      seasonCounts: state.seasonCounts,
                      weekendCounts: state.weekendCounts,
                      timeOfDayCounts: state.timeOfDayCounts,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

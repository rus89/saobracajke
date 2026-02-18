import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
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
                  _SectionHeader(title: 'Sekcija 1: Ključni pokazatelji'),
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
                  _SectionHeader(title: 'Sekcija 2: Trendovi i Analize'),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SectionTwoCharts(
                      monthlyAccidents: state.monthlyAccidents,
                      typeMonthlyAccidents: state.typeMonthlyAccidents,
                      stationAccidents: state.stationAccidents,
                    ),
                  ),
                  _SectionHeader(title: 'Sekcija 3: Vremenska Distribucija'),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title, style: AppTheme.sectionTitleStyle),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }
}

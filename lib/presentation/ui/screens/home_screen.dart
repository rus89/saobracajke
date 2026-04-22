// ABOUTME: Dashboard home screen showing key accident metrics, trend charts, and temporal distribution.
// ABOUTME: Reads DashboardState via Riverpod and renders three chart sections with year/department filters.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_one_header.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_three_charts.dart';
import 'package:saobracajke/presentation/ui/widgets/dashboard/section_two_charts.dart';
import 'package:saobracajke/presentation/ui/widgets/section_header.dart';
import 'package:saobracajke/presentation/ui/widgets/year_department_filter.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    final notifier = ref.read(dashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: asyncState.maybeWhen(
          data: (state) {
            final theme = Theme.of(context);
            final year = state.selectedYear;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pregled', style: theme.textTheme.titleMedium),
                if (year != null)
                  Text(
                    'Saobraćajne nezgode · $year',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            );
          },
          orElse: () => const Text('Pregled'),
        ),
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => Semantics(
            label: 'Loading dashboard data',
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialBanner(
                  content: Text(error.toString()),
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
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          data: (state) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (asyncState.isLoading) const LinearProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: YearDepartmentFilter(
                          selectedYear: state.selectedYear,
                          availableYears: state.availableYears,
                          selectedDept: state.selectedDept,
                          departments: state.departments,
                          onYearChanged: (year) {
                            if (year != null) {
                              ref
                                  .read(dashboardProvider.notifier)
                                  .setYear(year);
                            }
                          },
                          onDepartmentChanged: (dept) {
                            ref
                                .read(dashboardProvider.notifier)
                                .setDepartment(dept);
                          },
                        ),
                      ),
                      const SectionHeader(label: 'KLJUČNI POKAZATELJI'),
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
                          materialDamageAccidentsDelta:
                              state.materialDamageDelta,
                        ),
                      ),
                      const SectionHeader(label: 'TRENDOVI'),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: SectionTwoCharts(
                          monthlyAccidents: state.monthlyAccidents,
                          typeMonthlyAccidents: state.typeMonthlyAccidents,
                          stationAccidents: state.stationAccidents,
                        ),
                      ),
                      const SectionHeader(label: 'VREMENSKA DISTRIBUCIJA'),
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
      ),
    );
  }
}


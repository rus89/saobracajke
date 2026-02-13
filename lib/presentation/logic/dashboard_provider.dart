import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/di/repository_providers.dart';
import '../../domain/accident_types.dart';
import '../../domain/repositories/traffic_repository.dart';

/// Dashboard-only state: filters, metadata, and chart aggregates.
/// Map/list accident list is held by [accidentsProvider].
class DashboardState {
  final List<String> departments;
  final List<int> availableYears;
  final bool isLoading;

  final String? selectedDept;
  final int? selectedYear;

  final int totalAccidents;
  final int totalAccidentsPrevYear;
  final Map<String, int> accidentTypeCounts;
  final Map<String, int> topCities;
  final Map<String, int> seasonCounts;
  final Map<String, int> timeOfDayCounts;
  final Map<String, int> weekendCounts;
  final Map<int, int> monthlyAccidents;
  final Map<String, Map<int, int>> typeMonthlyAccidents;
  final Map<String, int> stationAccidents;

  const DashboardState({
    this.departments = const [],
    this.availableYears = const [],
    this.isLoading = false,
    this.selectedDept,
    this.selectedYear,
    this.totalAccidents = 0,
    this.totalAccidentsPrevYear = 0,
    this.accidentTypeCounts = const {},
    this.topCities = const {},
    this.seasonCounts = const {},
    this.timeOfDayCounts = const {},
    this.weekendCounts = const {},
    this.monthlyAccidents = const {},
    this.typeMonthlyAccidents = const {},
    this.stationAccidents = const {},
  });

  int get deltaAccidents => totalAccidents - totalAccidentsPrevYear;
  int get fatalitiesCount => accidentTypeCounts[AccidentTypes.fatalities] ?? 0;
  int get injuriesCount => accidentTypeCounts[AccidentTypes.injuries] ?? 0;
  int get materialDamageCount =>
      accidentTypeCounts[AccidentTypes.materialDamage] ?? 0;

  DashboardState copyWith({
    List<String>? departments,
    List<int>? availableYears,
    bool? isLoading,
    String? selectedDept = '_UNSET_',
    Object? selectedYear = '_UNSET_',
    int? totalAccidents,
    int? totalAccidentsPrevYear,
    Map<String, int>? accidentTypeCounts,
    Map<String, int>? topCities,
    Map<String, int>? seasonCounts,
    Map<String, int>? timeOfDayCounts,
    Map<String, int>? weekendCounts,
    Map<int, int>? monthlyAccidents,
    Map<String, Map<int, int>>? typeMonthlyAccidents,
    Map<String, int>? stationAccidents,
  }) {
    return DashboardState(
      departments: departments ?? this.departments,
      availableYears: availableYears ?? this.availableYears,
      isLoading: isLoading ?? this.isLoading,
      selectedDept: selectedDept != '_UNSET_'
          ? selectedDept
          : this.selectedDept,
      selectedYear: selectedYear != '_UNSET_'
          ? selectedYear as int?
          : this.selectedYear,
      totalAccidents: totalAccidents ?? this.totalAccidents,
      totalAccidentsPrevYear:
          totalAccidentsPrevYear ?? this.totalAccidentsPrevYear,
      accidentTypeCounts: accidentTypeCounts ?? this.accidentTypeCounts,
      topCities: topCities ?? this.topCities,
      seasonCounts: seasonCounts ?? this.seasonCounts,
      timeOfDayCounts: timeOfDayCounts ?? this.timeOfDayCounts,
      weekendCounts: weekendCounts ?? this.weekendCounts,
      monthlyAccidents: monthlyAccidents ?? this.monthlyAccidents,
      typeMonthlyAccidents: typeMonthlyAccidents ?? this.typeMonthlyAccidents,
      stationAccidents: stationAccidents ?? this.stationAccidents,
    );
  }
}

/// Manages dashboard filters and aggregates only. Does not load accident list;
/// [accidentsProvider] reacts to filter changes and loads map/list data.
class DashboardNotifier extends StateNotifier<DashboardState> {
  final TrafficRepository _repo;

  DashboardNotifier(TrafficRepository repo)
    : _repo = repo,
      super(const DashboardState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final depts = await _repo.getDepartments();
      final years = await _repo.getAvailableYears();
      final defaultYear = years.isNotEmpty ? years.first : DateTime.now().year;
      state = state.copyWith(
        departments: depts,
        availableYears: years,
        selectedYear: defaultYear,
      );
      await _loadDashboardData();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadDashboardData() async {
    if (state.selectedYear == null) return;
    final year = state.selectedYear!;
    final dept = state.selectedDept;
    try {
      final results = await Future.wait([
        _repo.getTotalAccidentsForYear(year, department: dept),
        _repo.getTotalAccidentsForYear(year - 1, department: dept),
        _repo.getAccidentTypeCountsForYear(year, department: dept),
        _repo.getTopCitiesForYear(year, department: dept),
        _repo.getAccidentsBySeasonForYear(year, department: dept),
        _repo.getAccidentsByTimeOfDayForYear(year, department: dept),
        _repo.getAccidentsByWeekendForYear(year, department: dept),
        _repo.getAccidentsByMonthForYear(year, department: dept),
        _repo.getAccidentTypesByMonthForYear(year, department: dept),
        dept != null
            ? _repo.getAccidentsByStationForDepartment(year, dept)
            : Future.value(<String, int>{}),
      ]);
      state = state.copyWith(
        totalAccidents: results[0] as int,
        totalAccidentsPrevYear: results[1] as int,
        accidentTypeCounts: results[2] as Map<String, int>,
        topCities: results[3] as Map<String, int>,
        seasonCounts: results[4] as Map<String, int>,
        timeOfDayCounts: results[5] as Map<String, int>,
        weekendCounts: results[6] as Map<String, int>,
        monthlyAccidents: results[7] as Map<int, int>,
        typeMonthlyAccidents: results[8] as Map<String, Map<int, int>>,
        stationAccidents: results[9] as Map<String, int>,
      );
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }

  void setYear(int year) {
    state = state.copyWith(selectedYear: year);
    _loadDashboardData();
  }

  void setDepartment(String? dept) {
    state = state.copyWith(selectedDept: dept);
    _loadDashboardData();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier(ref.read(repositoryProvider));
    });

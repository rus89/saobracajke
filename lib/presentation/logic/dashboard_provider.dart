// ABOUTME: Dashboard state management: filters (year, department) and all chart/aggregate data.
// ABOUTME: DashboardNotifier loads data from TrafficRepository and exposes year-over-year deltas.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/repository_providers.dart';
import '../../domain/accident_types.dart';
import '../../domain/repositories/traffic_repository.dart';

const _keySelectedYear = 'dashboard_selected_year';
const _keySelectedDept = 'dashboard_selected_department';

/// Dashboard-only state: filters, metadata, and chart aggregates.
/// Map/list accident list is held by [accidentsProvider].
class DashboardState {
  const DashboardState({
    this.departments = const [],
    this.availableYears = const [],
    this.selectedDept,
    this.selectedYear,
    this.totalAccidents = 0,
    this.totalAccidentsPrevYear = 0,
    this.accidentTypeCounts = const {},
    this.accidentTypeCountsPrevYear = const {},
    this.topCities = const {},
    this.seasonCounts = const {},
    this.timeOfDayCounts = const {},
    this.weekendCounts = const {},
    this.monthlyAccidents = const {},
    this.typeMonthlyAccidents = const {},
    this.stationAccidents = const {},
  });
  final List<String> departments;
  final List<int> availableYears;

  final String? selectedDept;
  final int? selectedYear;

  final int totalAccidents;
  final int totalAccidentsPrevYear;
  final Map<String, int> accidentTypeCounts;
  final Map<String, int> accidentTypeCountsPrevYear;
  final Map<String, int> topCities;
  final Map<String, int> seasonCounts;
  final Map<String, int> timeOfDayCounts;
  final Map<String, int> weekendCounts;
  final Map<int, int> monthlyAccidents;
  final Map<String, Map<int, int>> typeMonthlyAccidents;
  final Map<String, int> stationAccidents;

  int get deltaAccidents => totalAccidents - totalAccidentsPrevYear;
  int get fatalitiesCount => accidentTypeCounts[AccidentTypes.fatalities] ?? 0;
  int get injuriesCount => accidentTypeCounts[AccidentTypes.injuries] ?? 0;
  int get materialDamageCount =>
      accidentTypeCounts[AccidentTypes.materialDamage] ?? 0;

  int get _fatalitiesPrev =>
      accidentTypeCountsPrevYear[AccidentTypes.fatalities] ?? 0;
  int get _injuriesPrev =>
      accidentTypeCountsPrevYear[AccidentTypes.injuries] ?? 0;
  int get _materialDamagePrev =>
      accidentTypeCountsPrevYear[AccidentTypes.materialDamage] ?? 0;
  int get fatalitiesDelta => fatalitiesCount - _fatalitiesPrev;
  int get injuriesDelta => injuriesCount - _injuriesPrev;
  int get materialDamageDelta => materialDamageCount - _materialDamagePrev;

  DashboardState copyWith({
    List<String>? departments,
    List<int>? availableYears,
    String? selectedDept = '_UNSET_',
    Object? selectedYear = '_UNSET_',
    int? totalAccidents,
    int? totalAccidentsPrevYear,
    Map<String, int>? accidentTypeCounts,
    Map<String, int>? accidentTypeCountsPrevYear,
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
      accidentTypeCountsPrevYear:
          accidentTypeCountsPrevYear ?? this.accidentTypeCountsPrevYear,
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
class DashboardNotifier extends AsyncNotifier<DashboardState> {
  late final TrafficRepository _repo;
  late final SharedPreferences _prefs;

  @override
  Future<DashboardState> build() async {
    _repo = ref.read(repositoryProvider);
    _prefs = ref.read(sharedPreferencesProvider);
    return _initialize();
  }

  Future<DashboardState> _initialize() async {
    final depts = await _repo.getDepartments();
    final years = await _repo.getAvailableYears();
    final defaultYear = years.isNotEmpty ? years.first : DateTime.now().year;

    // Restore saved filters; ignore values that are no longer valid.
    final savedYear = _prefs.getInt(_keySelectedYear);
    final savedDept = _prefs.getString(_keySelectedDept);
    final initialYear =
        (savedYear != null && years.contains(savedYear)) ? savedYear : defaultYear;
    final initialDept =
        (savedDept != null && depts.contains(savedDept)) ? savedDept : null;

    final baseState = DashboardState(
      departments: depts,
      availableYears: years,
      selectedYear: initialYear,
      selectedDept: initialDept,
    );
    return _loadDashboardData(baseState);
  }

  Future<DashboardState> _loadDashboardData(DashboardState current) async {
    if (current.selectedYear == null) return current;
    final year = current.selectedYear!;
    final dept = current.selectedDept;
    final results = await Future.wait([
      _repo.getTotalAccidentsForYear(year, department: dept),
      _repo.getTotalAccidentsForYear(year - 1, department: dept),
      _repo.getAccidentTypeCountsForYear(year, department: dept),
      _repo.getAccidentTypeCountsForYear(year - 1, department: dept),
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
    return current.copyWith(
      totalAccidents: results[0] as int,
      totalAccidentsPrevYear: results[1] as int,
      accidentTypeCounts: results[2] as Map<String, int>,
      accidentTypeCountsPrevYear: results[3] as Map<String, int>,
      topCities: results[4] as Map<String, int>,
      seasonCounts: results[5] as Map<String, int>,
      timeOfDayCounts: results[6] as Map<String, int>,
      weekendCounts: results[7] as Map<String, int>,
      monthlyAccidents: results[8] as Map<int, int>,
      typeMonthlyAccidents: results[9] as Map<String, Map<int, int>>,
      stationAccidents: results[10] as Map<String, int>,
    );
  }

  /// Transitions to loading, runs [action], and sets the result or error.
  Future<void> _runGuarded(Future<DashboardState> Function() action) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(action);
  }

  Future<void> retry() => _runGuarded(_initialize);

  Future<void> setYear(int year) async {
    final current = state.value;
    if (current == null) return;
    unawaited(_prefs.setInt(_keySelectedYear, year));
    final updated = current.copyWith(selectedYear: year);
    return _runGuarded(() => _loadDashboardData(updated));
  }

  Future<void> setDepartment(String? dept) async {
    final current = state.value;
    if (current == null) return;
    if (dept == null) {
      unawaited(_prefs.remove(_keySelectedDept));
    } else {
      unawaited(_prefs.setString(_keySelectedDept, dept));
    }
    final updated = current.copyWith(selectedDept: dept);
    return _runGuarded(() => _loadDashboardData(updated));
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardState>(
      DashboardNotifier.new,
    );

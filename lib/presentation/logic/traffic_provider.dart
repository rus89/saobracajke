import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/traffic_repository.dart';
import '../../domain/models/accident_model.dart';

class TrafficState {
  final List<AccidentModel> accidents; // For map/list views only
  final List<String> departments;
  final List<int> availableYears;
  final bool isLoading;

  // Active Filters
  final String? selectedDept;
  final int? selectedYear;

  // Dashboard Aggregates (computed from DB, not from loaded rows)
  final int totalAccidents;
  final int totalAccidentsPrevYear;
  final Map<String, int> accidentTypeCounts;
  final Map<String, int> topCities;
  final Map<String, int> seasonCounts;
  final Map<String, int> timeOfDayCounts;
  final Map<String, int> weekendCounts;

  TrafficState({
    this.accidents = const [],
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
  });

  // Computed properties
  int get deltaAccidents => totalAccidents - totalAccidentsPrevYear;

  int get fatalitiesCount => accidentTypeCounts['Sa poginulim'] ?? 0;
  int get injuriesCount => accidentTypeCounts['Sa povredjenim'] ?? 0;
  int get materialDamageCount => accidentTypeCounts['Sa mat.stetom'] ?? 0;

  TrafficState copyWith({
    List<AccidentModel>? accidents,
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
  }) {
    return TrafficState(
      accidents: accidents ?? this.accidents,
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
    );
  }
}

class TrafficNotifier extends StateNotifier<TrafficState> {
  final TrafficRepository _repo;

  TrafficNotifier(this._repo) : super(TrafficState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load metadata
      final depts = await _repo.getDepartments();
      final years = await _repo.getAvailableYears();

      // Set default year to most recent
      final defaultYear = years.isNotEmpty ? years.first : DateTime.now().year;

      state = state.copyWith(
        departments: depts,
        availableYears: years,
        selectedYear: defaultYear,
      );

      // Load dashboard data for default year
      await _loadDashboardData();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint("Error initializing: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadDashboardData() async {
    if (state.selectedYear == null) return;

    final year = state.selectedYear!;
    final dept = state.selectedDept;

    try {
      // Load all aggregates in parallel
      final results = await Future.wait([
        _repo.getTotalAccidentsForYear(year, department: dept),
        _repo.getTotalAccidentsForYear(year - 1, department: dept),
        _repo.getAccidentTypeCountsForYear(year, department: dept),
        _repo.getTopCitiesForYear(year, department: dept),
        _repo.getAccidentsBySeasonForYear(year, department: dept),
        _repo.getAccidentsByTimeOfDayForYear(year, department: dept),
        _repo.getAccidentsByWeekendForYear(year, department: dept),
      ]);

      state = state.copyWith(
        totalAccidents: results[0] as int,
        totalAccidentsPrevYear: results[1] as int,
        accidentTypeCounts: results[2] as Map<String, int>,
        topCities: results[3] as Map<String, int>,
        seasonCounts: results[4] as Map<String, int>,
        timeOfDayCounts: results[5] as Map<String, int>,
        weekendCounts: results[6] as Map<String, int>,
      );
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
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

  // For map/list views later
  Future<void> loadAccidents() async {
    // This will be used for map view, keep it limited
    try {
      final results = await _repo.getAccidents(department: state.selectedDept);
      state = state.copyWith(accidents: results);
    } catch (e) {
      debugPrint("Error loading accidents: $e");
    }
  }
}

final repositoryProvider = Provider((ref) => TrafficRepository());

final trafficProvider = StateNotifierProvider<TrafficNotifier, TrafficState>((
  ref,
) {
  return TrafficNotifier(ref.read(repositoryProvider));
});

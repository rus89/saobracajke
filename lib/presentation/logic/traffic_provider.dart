import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/traffic_repository.dart';
import '../../domain/models/accident_model.dart';

//----------------------------------------------------------------------------
class TrafficState {
  final List<AccidentModel> accidents;
  final List<String> departments;
  final bool isLoading;

  // Active Filters
  final String? selectedDept;
  final DateTime? startDate;
  final DateTime? endDate;

  TrafficState({
    this.accidents = const [],
    this.departments = const [],
    this.isLoading = false,
    this.selectedDept,
    this.startDate,
    this.endDate,
  });

  TrafficState copyWith({
    List<AccidentModel>? accidents,
    List<String>? departments,
    bool? isLoading,
    String? selectedDept,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TrafficState(
      accidents: accidents ?? this.accidents,
      departments: departments ?? this.departments,
      isLoading: isLoading ?? this.isLoading,
      selectedDept: selectedDept ?? this.selectedDept,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// The Notifier (Controller)
class TrafficNotifier extends StateNotifier<TrafficState> {
  final TrafficRepository _repo;

  TrafficNotifier(this._repo) : super(TrafficState()) {
    _initialize();
  }

  //-------------------------------------------------------------------------------
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load departments first
      final depts = await _repo.getDepartments();
      state = state.copyWith(departments: depts);

      // Then load initial accidents
      await loadAccidents();
    } catch (e) {
      debugPrint("Error initializing: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  //-------------------------------------------------------------------------------
  Future<void> loadAccidents() async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await _repo.getAccidents(
        department: state.selectedDept,
        startDate: state.startDate,
        endDate: state.endDate,
      );
      state = state.copyWith(accidents: results, isLoading: false);
    } catch (e) {
      debugPrint("Error loading accidents: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  // Filter Methods
  void setDepartment(String? dept) {
    state = state.copyWith(selectedDept: dept);
    loadAccidents(); // Auto-refresh when filter changes
  }

  void setDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
    loadAccidents();
  }
}

// THE PROVIDERS (The Global Access Points)
final repositoryProvider = Provider((ref) => TrafficRepository());

final trafficProvider = StateNotifierProvider<TrafficNotifier, TrafficState>((
  ref,
) {
  return TrafficNotifier(ref.read(repositoryProvider));
});

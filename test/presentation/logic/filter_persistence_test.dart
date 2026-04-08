// ABOUTME: Tests for dashboard filter persistence via SharedPreferences.
// ABOUTME: Verifies that year/department selections are saved and restored across sessions.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/di/repository_providers.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/domain/repositories/traffic_repository.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> makeContainer({
    Map<String, Object> initialPrefs = const {},
    TrafficRepository? repo,
  }) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo ?? _FakeRepo()),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<DashboardState> waitForData(ProviderContainer container) async {
    for (var i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      final s = container.read(dashboardProvider);
      if (s.hasValue) return s.requireValue;
    }
    throw StateError('dashboardProvider did not settle to data state');
  }

  group('Filter persistence — saving', () {
    test('setYear persists selected year to SharedPreferences', () async {
      final container = await makeContainer();
      await waitForData(container);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getInt('dashboard_selected_year'), isNull);

      await container.read(dashboardProvider.notifier).setYear(2022);
      await waitForData(container);

      expect(prefs.getInt('dashboard_selected_year'), equals(2022));
    });

    test('setDepartment persists selected department to SharedPreferences',
        () async {
      final container = await makeContainer();
      await waitForData(container);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('dashboard_selected_department'), isNull);

      await container
          .read(dashboardProvider.notifier)
          .setDepartment('PU Beograd');
      await waitForData(container);

      expect(
        prefs.getString('dashboard_selected_department'),
        equals('PU Beograd'),
      );
    });

    test(
        'setDepartment with null removes saved department from SharedPreferences',
        () async {
      final container = await makeContainer(
        initialPrefs: {'dashboard_selected_department': 'PU Beograd'},
      );
      await waitForData(container);

      await container.read(dashboardProvider.notifier).setDepartment(null);
      await waitForData(container);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('dashboard_selected_department'), isNull);
    });
  });

  group('Filter persistence — restoring', () {
    test('restores saved year on initialization', () async {
      final container = await makeContainer(
        initialPrefs: {'dashboard_selected_year': 2022},
      );
      final state = await waitForData(container);

      expect(state.selectedYear, equals(2022));
    });

    test('restores saved department on initialization', () async {
      final container = await makeContainer(
        initialPrefs: {'dashboard_selected_department': 'PU Novi Sad'},
      );
      final state = await waitForData(container);

      expect(state.selectedDept, equals('PU Novi Sad'));
    });

    test('falls back to latest year when no year is saved', () async {
      final container = await makeContainer();
      final state = await waitForData(container);

      // _FakeRepo returns [2023, 2022]; default is first = 2023
      expect(state.selectedYear, equals(2023));
    });

    test('ignores saved year not present in available years', () async {
      final container = await makeContainer(
        // 1999 is not in _FakeRepo.getAvailableYears()
        initialPrefs: {'dashboard_selected_year': 1999},
      );
      final state = await waitForData(container);

      expect(state.selectedYear, equals(2023));
    });

    test('ignores saved department not present in available departments',
        () async {
      final container = await makeContainer(
        // 'PU Zaječar' is not in _FakeRepo.getDepartments()
        initialPrefs: {
          'dashboard_selected_department': 'PU Zaječar',
        },
      );
      final state = await waitForData(container);

      expect(state.selectedDept, isNull);
    });
  });
}

class _FakeRepo implements TrafficRepository {
  @override
  Future<List<String>> getDepartments() async => ['PU Beograd', 'PU Novi Sad'];

  @override
  Future<List<int>> getAvailableYears() async => [2023, 2022];

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async =>
      100;

  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(int year,
          {String? department}) async =>
      {};

  @override
  Future<Map<String, int>> getTopCitiesForYear(int year,
          {String? department}) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsBySeasonForYear(int year,
          {String? department}) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(int year,
          {String? department}) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsByWeekendForYear(int year,
          {String? department}) async =>
      {};

  @override
  Future<Map<int, int>> getAccidentsByMonthForYear(int year,
          {String? department}) async =>
      {};

  @override
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(int year,
          {String? department}) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsByStationForDepartment(
          int year, String department) async =>
      {};

  @override
  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword,
  }) async =>
      [];
}

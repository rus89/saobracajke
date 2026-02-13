import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/di/repository_providers.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/domain/repositories/traffic_repository.dart';
import 'package:saobracajke/presentation/logic/accidents_provider.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';

void main() {
  group('DashboardState', () {
    test('copyWith preserves unset fields', () {
      const state = DashboardState(
        departments: ['A'],
        availableYears: [2022],
        selectedYear: 2022,
        totalAccidents: 10,
        totalAccidentsPrevYear: 8,
      );
      final next = state.copyWith(selectedYear: 2023);
      expect(next.selectedYear, 2023);
      expect(next.departments, state.departments);
      expect(next.totalAccidents, 10);
    });

    test('deltaAccidents is totalAccidents minus totalAccidentsPrevYear', () {
      const state = DashboardState(
        totalAccidents: 100,
        totalAccidentsPrevYear: 80,
      );
      expect(state.deltaAccidents, 20);
    });

    test('fatalitiesCount and injuriesCount read from accidentTypeCounts', () {
      const state = DashboardState(
        accidentTypeCounts: {
          'Sa poginulim': 3,
          'Sa povredjenim': 7,
          'Sa mat.stetom': 5,
        },
      );
      expect(state.fatalitiesCount, 3);
      expect(state.injuriesCount, 7);
      expect(state.materialDamageCount, 5);
    });
  });

  group('DashboardNotifier', () {
    late FakeTrafficRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeTrafficRepository();
      container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(fakeRepo)],
      );
    });

    tearDown(() => container.dispose());

    Future<void> waitForInit() async {
      container.read(dashboardProvider);
      for (var i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        if (!container.read(dashboardProvider).isLoading) return;
      }
      throw StateError('Timeout waiting for DashboardNotifier init');
    }

    test(
      'after init, state has departments, years, default year, and loading false',
      () async {
        await waitForInit();
        final state = container.read(dashboardProvider);
        expect(state.departments, ['Dept1']);
        expect(state.availableYears, [2023]);
        expect(state.selectedYear, 2023);
        expect(state.isLoading, isFalse);
      },
    );

    test('setYear updates selectedYear and reloads dashboard', () async {
      await waitForInit();
      final notifier = container.read(dashboardProvider.notifier);
      notifier.setYear(2022);
      expect(container.read(dashboardProvider).selectedYear, 2022);
      expect(fakeRepo.getTotalAccidentsForYearCalls, contains(2022));
    });

    test('setDepartment updates selectedDept and reloads dashboard', () async {
      await waitForInit();
      final notifier = container.read(dashboardProvider.notifier);
      notifier.setDepartment('Belgrade');
      expect(container.read(dashboardProvider).selectedDept, 'Belgrade');
      expect(fakeRepo.getTotalAccidentsForYearCalls, isNotEmpty);
    });
  });

  group('accidentsProvider', () {
    late FakeTrafficRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeTrafficRepository();
      container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(fakeRepo)],
      );
    });

    tearDown(() => container.dispose());

    Future<void> waitForDashboardInit() async {
      container.read(dashboardProvider);
      for (var i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        if (!container.read(dashboardProvider).isLoading) return;
      }
      throw StateError('Timeout waiting for dashboard init');
    }

    test('populates accidents list from current dashboard filters', () async {
      await waitForDashboardInit();
      final accidents = await container.read(accidentsProvider.future);
      expect(accidents.length, 1);
      expect(accidents.first.id, 'test-id');
    });
  });
}

class FakeTrafficRepository implements TrafficRepository {
  final List<int> getTotalAccidentsForYearCalls = [];

  @override
  Future<List<String>> getDepartments() async => ['Dept1'];

  @override
  Future<List<int>> getAvailableYears() async => [2023];

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async {
    getTotalAccidentsForYearCalls.add(year);
    return 10;
  }

  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(
    int year, {
    String? department,
  }) async => {'Sa povredjenim': 5};

  @override
  Future<Map<String, int>> getTopCitiesForYear(
    int year, {
    String? department,
  }) async => {};

  @override
  Future<Map<String, int>> getAccidentsBySeasonForYear(
    int year, {
    String? department,
  }) async => {};

  @override
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(
    int year, {
    String? department,
  }) async => {};

  @override
  Future<Map<String, int>> getAccidentsByWeekendForYear(
    int year, {
    String? department,
  }) async => {};

  @override
  Future<Map<int, int>> getAccidentsByMonthForYear(
    int year, {
    String? department,
  }) async => {};

  @override
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(
    int year, {
    String? department,
  }) async => {};

  @override
  Future<Map<String, int>> getAccidentsByStationForDepartment(
    int year,
    String department,
  ) async => {};

  @override
  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword,
  }) async {
    return [
      AccidentModel(
        id: 'test-id',
        department: 'D',
        station: 'S',
        type: 'T',
        date: DateTime(2023, 1, 1),
        lat: 44.0,
        lng: 20.0,
        participants: '2',
        officialDesc: null,
      ),
    ];
  }
}

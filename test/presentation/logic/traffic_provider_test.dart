import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/di/repository_providers.dart';
import 'package:saobracajke/domain/accident_types.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/domain/repositories/traffic_repository.dart';
import 'package:saobracajke/presentation/logic/accidents_provider.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns a fresh mock [SharedPreferences] with no saved values.
Future<SharedPreferences> _mockPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

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

    test(
      'fatalitiesDelta, injuriesDelta, materialDamageDelta are current minus prev year',
      () {
        const state = DashboardState(
          accidentTypeCounts: {
            AccidentTypes.fatalities: 10,
            AccidentTypes.injuries: 20,
            AccidentTypes.materialDamage: 30,
          },
          accidentTypeCountsPrevYear: {
            AccidentTypes.fatalities: 8,
            AccidentTypes.injuries: 18,
            AccidentTypes.materialDamage: 25,
          },
        );
        expect(state.fatalitiesDelta, 2);
        expect(state.injuriesDelta, 2);
        expect(state.materialDamageDelta, 5);
      },
    );
  });

  group('DashboardNotifier', () {
    late FakeTrafficRepository fakeRepo;
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      fakeRepo = FakeTrafficRepository();
      prefs = await _mockPrefs();
      container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(fakeRepo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() => container.dispose());

    Future<void> waitForData([ProviderContainer? c]) async {
      final cont = c ?? container;
      cont.read(dashboardProvider);
      for (var i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        final asyncVal = cont.read(dashboardProvider);
        if (asyncVal.hasValue && !asyncVal.isLoading) return;
      }
      throw StateError('Timeout waiting for DashboardNotifier init');
    }

    test(
      'after init, state has departments, years, default year, and loading false',
      () async {
        await waitForData();
        final asyncVal = container.read(dashboardProvider);
        expect(asyncVal.hasValue, isTrue);
        expect(asyncVal.isLoading, isFalse);
        final state = asyncVal.requireValue;
        expect(state.departments, ['Dept1']);
        expect(state.availableYears, [2023]);
        expect(state.selectedYear, 2023);
      },
    );

    test('setYear updates selectedYear and reloads dashboard', () async {
      await waitForData();
      final notifier = container.read(dashboardProvider.notifier);
      await notifier.setYear(2022);
      // After calling setYear, the year should update
      for (var i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        final asyncVal = container.read(dashboardProvider);
        if (asyncVal.hasValue && !asyncVal.isLoading) break;
      }
      final state = container.read(dashboardProvider).requireValue;
      expect(state.selectedYear, 2022);
      expect(fakeRepo.getTotalAccidentsForYearCalls, contains(2022));
    });

    test('setDepartment updates selectedDept and reloads dashboard', () async {
      await waitForData();
      final notifier = container.read(dashboardProvider.notifier);
      await notifier.setDepartment('Belgrade');
      for (var i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        final asyncVal = container.read(dashboardProvider);
        if (asyncVal.hasValue && !asyncVal.isLoading) break;
      }
      final state = container.read(dashboardProvider).requireValue;
      expect(state.selectedDept, 'Belgrade');
      expect(fakeRepo.getTotalAccidentsForYearCalls, isNotEmpty);
    });

    test(
      'setYear sets isLoading true then false when dashboard data reloads',
      () async {
        final slowFake = SlowFakeTrafficRepository();
        final slowContainer = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithValue(slowFake),
            sharedPreferencesProvider.overrideWithValue(await _mockPrefs()),
          ],
        );
        addTearDown(slowContainer.dispose);
        await waitForData(slowContainer);
        expect(slowContainer.read(dashboardProvider).isLoading, isFalse);

        unawaited(slowContainer.read(dashboardProvider.notifier).setYear(2022));
        await Future.delayed(Duration.zero);
        expect(
          slowContainer.read(dashboardProvider).isLoading,
          isTrue,
          reason: 'Loading should be true while reloading after filter change',
        );

        for (var i = 0; i < 100; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          if (!slowContainer.read(dashboardProvider).isLoading) break;
        }
        expect(
          slowContainer.read(dashboardProvider).isLoading,
          isFalse,
          reason: 'Loading should be false after reload completes',
        );
        expect(
          slowContainer.read(dashboardProvider).requireValue.selectedYear,
          2022,
        );
      },
    );

    test(
      'setDepartment sets isLoading true then false when dashboard data reloads',
      () async {
        final slowFake = SlowFakeTrafficRepository();
        final slowContainer = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithValue(slowFake),
            sharedPreferencesProvider.overrideWithValue(await _mockPrefs()),
          ],
        );
        addTearDown(slowContainer.dispose);
        await waitForData(slowContainer);
        expect(slowContainer.read(dashboardProvider).isLoading, isFalse);

        unawaited(
          slowContainer
              .read(dashboardProvider.notifier)
              .setDepartment('Belgrade'),
        );
        await Future.delayed(Duration.zero);
        expect(
          slowContainer.read(dashboardProvider).isLoading,
          isTrue,
          reason: 'Loading should be true while reloading after filter change',
        );

        for (var i = 0; i < 100; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          if (!slowContainer.read(dashboardProvider).isLoading) break;
        }
        expect(
          slowContainer.read(dashboardProvider).isLoading,
          isFalse,
          reason: 'Loading should be false after reload completes',
        );
        expect(
          slowContainer.read(dashboardProvider).requireValue.selectedDept,
          'Belgrade',
        );
      },
    );

    test(
      'when repo throws during init, state contains error',
      () async {
        final throwingRepo = ThrowingInitFakeTrafficRepository();
        final c = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithValue(throwingRepo),
            sharedPreferencesProvider.overrideWithValue(await _mockPrefs()),
          ],
        );
        addTearDown(c.dispose);
        c.read(dashboardProvider);
        for (var i = 0; i < 100; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          if (!c.read(dashboardProvider).isLoading) break;
        }
        final asyncVal = c.read(dashboardProvider);
        expect(asyncVal.isLoading, isFalse);
        expect(asyncVal.hasError, isTrue);
        expect(asyncVal.error, isNotNull);
      },
    );

    test(
      'when repo throws during load after setYear, state contains error',
      () async {
        final throwingRepo = ThrowingLoadFakeTrafficRepository(
          throwForYear: 2020,
        );
        final c = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithValue(throwingRepo),
            sharedPreferencesProvider.overrideWithValue(await _mockPrefs()),
          ],
        );
        addTearDown(c.dispose);
        await waitForData(c);
        expect(c.read(dashboardProvider).hasError, isFalse);

        await c.read(dashboardProvider.notifier).setYear(2020);
        for (var i = 0; i < 100; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          final s = c.read(dashboardProvider);
          if (!s.isLoading && s.hasError) break;
        }
        final asyncVal = c.read(dashboardProvider);
        expect(asyncVal.hasError, isTrue);
        expect(asyncVal.error, isNotNull);
      },
    );

    test(
      'retry clears error and reloads; when repo then succeeds, state has no error',
      () async {
        final repo = ThrowingOnceInitFakeTrafficRepository();
        final c = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(await _mockPrefs()),
          ],
        );
        addTearDown(c.dispose);
        c.read(dashboardProvider);
        for (var i = 0; i < 100; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          if (!c.read(dashboardProvider).isLoading) break;
        }
        expect(c.read(dashboardProvider).hasError, isTrue);

        await c.read(dashboardProvider.notifier).retry();
        for (var i = 0; i < 100; i++) {
          await Future.delayed(const Duration(milliseconds: 20));
          final asyncVal = c.read(dashboardProvider);
          if (asyncVal.hasValue && !asyncVal.isLoading) break;
        }
        final asyncVal = c.read(dashboardProvider);
        expect(asyncVal.hasError, isFalse);
        expect(asyncVal.hasValue, isTrue);
        expect(asyncVal.requireValue.departments, isNotEmpty);
      },
    );

    test(
      'after init, YoY deltas for fatalities, injuries, material damage match current minus prev year',
      () async {
        final repo = YoYDeltasFakeTrafficRepository();
        final c = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(await _mockPrefs()),
          ],
        );
        addTearDown(c.dispose);
        await waitForData(c);
        final state = c.read(dashboardProvider).requireValue;
        expect(state.fatalitiesDelta, 2);
        expect(state.injuriesDelta, 2);
        expect(state.materialDamageDelta, 5);
      },
    );
  });

  group('accidentsProvider', () {
    late FakeTrafficRepository fakeRepo;
    late ProviderContainer container;

    setUp(() async {
      fakeRepo = FakeTrafficRepository();
      container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(fakeRepo),
          sharedPreferencesProvider.overrideWithValue(await _mockPrefs()),
        ],
      );
    });

    tearDown(() => container.dispose());

    Future<void> waitForDashboardInit() async {
      container.read(dashboardProvider);
      for (var i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
        final asyncVal = container.read(dashboardProvider);
        if (asyncVal.hasValue && !asyncVal.isLoading) return;
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

class SlowFakeTrafficRepository extends FakeTrafficRepository {
  static const _delay = Duration(milliseconds: 50);

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async {
    await Future.delayed(_delay);
    return super.getTotalAccidentsForYear(year, department: department);
  }

  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(
    int year, {
    String? department,
  }) async {
    await Future.delayed(_delay);
    return super.getAccidentTypeCountsForYear(year, department: department);
  }

  @override
  Future<Map<String, int>> getTopCitiesForYear(
    int year, {
    String? department,
  }) async {
    await Future.delayed(_delay);
    return super.getTopCitiesForYear(year, department: department);
  }

  @override
  Future<Map<String, int>> getAccidentsBySeasonForYear(
    int year, {
    String? department,
  }) async {
    await Future.delayed(_delay);
    return super.getAccidentsBySeasonForYear(year, department: department);
  }

  @override
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(
    int year, {
    String? department,
  }) async {
    await Future.delayed(_delay);
    return super.getAccidentsByTimeOfDayForYear(year, department: department);
  }

  @override
  Future<Map<String, int>> getAccidentsByWeekendForYear(
    int year, {
    String? department,
  }) async {
    await Future.delayed(_delay);
    return super.getAccidentsByWeekendForYear(year, department: department);
  }

  @override
  Future<Map<int, int>> getAccidentsByMonthForYear(
    int year, {
    String? department,
  }) async {
    await Future.delayed(_delay);
    return super.getAccidentsByMonthForYear(year, department: department);
  }

  @override
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(
    int year, {
    String? department,
  }) async {
    await Future.delayed(_delay);
    return super.getAccidentTypesByMonthForYear(year, department: department);
  }

  @override
  Future<Map<String, int>> getAccidentsByStationForDepartment(
    int year,
    String department,
  ) async {
    await Future.delayed(_delay);
    return super.getAccidentsByStationForDepartment(year, department);
  }
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

class ThrowingInitFakeTrafficRepository extends FakeTrafficRepository {
  @override
  Future<List<String>> getDepartments() async {
    throw Exception('Init failed');
  }
}

class ThrowingLoadFakeTrafficRepository extends FakeTrafficRepository {
  ThrowingLoadFakeTrafficRepository({required this.throwForYear});
  final int throwForYear;

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async {
    if (year == throwForYear) throw Exception('Load failed');
    return super.getTotalAccidentsForYear(year, department: department);
  }
}

class ThrowingOnceInitFakeTrafficRepository extends FakeTrafficRepository {
  int _getDepartmentsCalls = 0;

  @override
  Future<List<String>> getDepartments() async {
    _getDepartmentsCalls++;
    if (_getDepartmentsCalls == 1) throw Exception('First init failed');
    return super.getDepartments();
  }
}

class YoYDeltasFakeTrafficRepository extends FakeTrafficRepository {
  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(
    int year, {
    String? department,
  }) async {
    if (year == 2023) {
      return {
        AccidentTypes.fatalities: 10,
        AccidentTypes.injuries: 20,
        AccidentTypes.materialDamage: 30,
      };
    }
    if (year == 2022) {
      return {
        AccidentTypes.fatalities: 8,
        AccidentTypes.injuries: 18,
        AccidentTypes.materialDamage: 25,
      };
    }
    return {};
  }
}

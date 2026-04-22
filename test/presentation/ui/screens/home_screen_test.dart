// ABOUTME: Widget tests for the dashboard home screen and its three section widgets.
// ABOUTME: Tests loading, error, data states, filter presence, and section content rendering.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/di/repository_providers.dart';
import 'package:saobracajke/domain/accident_types.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/domain/repositories/traffic_repository.dart';
import 'package:saobracajke/presentation/ui/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  group('HomeScreen', () {
    testWidgets('shows progress indicator while loading',
        (WidgetTester tester) async {
      final repo = _SlowRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // First frame: notifier starts async build, should show loading
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message and retry button when loading fails',
        (WidgetTester tester) async {
      final repo = _FailingRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Pokušaj ponovo'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('retry button triggers reload after error',
        (WidgetTester tester) async {
      final repo = _FailingRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);
      expect(find.text('Pokušaj ponovo'), findsOneWidget);

      // Tap retry — still fails, so error should remain
      await tester.tap(find.text('Pokušaj ponovo'));
      await _waitForSettle(tester);
      expect(find.text('Pokušaj ponovo'), findsOneWidget);
    });

    testWidgets('renders all three sections with data',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('KLJUČNI POKAZATELJI'), findsOneWidget);
      expect(find.text('TRENDOVI'), findsOneWidget);
      expect(find.text('VREMENSKA DISTRIBUCIJA'), findsOneWidget);
    });

    testWidgets('renders app bar title', (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Pregled'), findsOneWidget);
      expect(find.text('Saobraćajne nezgode · 2023'), findsOneWidget);
    });

    testWidgets('filter dropdowns are present with data state',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      // Year and department filter chips
      expect(find.byType(DropdownButton<int>), findsOneWidget);
      expect(find.byType(DropdownButton<String?>), findsOneWidget);
    });
  });

  group('SectionOneHeader via HomeScreen', () {
    testWidgets('displays total accident count', (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      // Total accidents: 1500 -> formatted as "1,500"
      expect(find.text('1,500'), findsOneWidget);
      expect(find.text('UKUPNO NESREĆA'), findsOneWidget);
    });

    testWidgets('displays year-over-year delta', (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      // Delta: 1500 - 1600 = -100
      expect(find.text('-100'), findsOneWidget);
      expect(find.text('vs prošle godine'), findsOneWidget);
    });

    testWidgets('displays mini-stat cards for injuries, fatalities, material damage',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('POVREĐENI'), findsOneWidget);
      expect(find.text('POGINULI'), findsOneWidget);
      expect(find.text('MAT. ŠTETA'), findsOneWidget);

      // Mini-stat counts: injuries=400, fatalities=50, materialDamage=1,050
      expect(find.text('400'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('1,050'), findsOneWidget);

      // Mini-stat deltas: injuries 400-450=-50, fatalities 50-60=-10,
      // materialDamage 1050-1090=-40
      expect(find.text('-50'), findsOneWidget);
      expect(find.text('-10'), findsOneWidget);
      expect(find.text('-40'), findsOneWidget);
    });
  });

  group('SectionTwoCharts via HomeScreen', () {
    testWidgets('displays monthly chart title', (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Nesreće po mesecima'), findsOneWidget);
    });

    testWidgets('displays type monthly chart title and legend labels',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Nesreće po tipu po mesecima'), findsOneWidget);

      // Legend labels from typeMonthlyAccidents keys
      expect(find.text(AccidentTypes.fatalities), findsOneWidget);
      expect(find.text(AccidentTypes.injuries), findsOneWidget);
      expect(find.text(AccidentTypes.materialDamage), findsOneWidget);
    });
  });

  group('SectionThreeTemporal via HomeScreen', () {
    testWidgets('displays season chart title', (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Nesreće po godišnjim dobima'), findsOneWidget);
    });

    testWidgets('displays weekend chart title', (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Nesreće: Radni dani vs Vikend'), findsOneWidget);
    });

    testWidgets('displays time of day chart title',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Nesreće po delu dana'), findsOneWidget);
    });

    testWidgets('displays season legend items with counts',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Proleće'), findsOneWidget);
      expect(find.text('Leto'), findsOneWidget);
      expect(find.text('Jesen'), findsOneWidget);
      expect(find.text('Zima'), findsOneWidget);

      // Season counts rendered as "$count nesreća" (only check values
      // unique to this section to avoid collisions with other sections)
      expect(find.text('450 nesreća'), findsOneWidget);
      expect(find.text('350 nesreća'), findsOneWidget);
    });

    testWidgets('displays weekend legend items with counts',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Radni dan'), findsOneWidget);
      expect(find.text('Vikend'), findsOneWidget);

      // Weekend counts rendered as "$count nesreća"
      expect(find.text('1100 nesreća'), findsOneWidget);
    });

    testWidgets('displays time of day legend items with counts',
        (WidgetTester tester) async {
      final repo = _FakeRepo();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(repo),
            sharedPreferencesProvider.overrideWithValue(_prefs),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await _waitForSettle(tester);

      expect(find.text('Jutro'), findsOneWidget);
      expect(find.text('Podne'), findsOneWidget);
      expect(find.text('Veče'), findsOneWidget);
      expect(find.text('Noć'), findsOneWidget);

      // Time-of-day count unique to this section
      expect(find.text('500 nesreća'), findsOneWidget);
    });
  });
}

/// Pumps frames until async providers settle.
Future<void> _waitForSettle(WidgetTester tester) async {
  for (var i = 0; i < 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () => Future.delayed(const Duration(milliseconds: 20)),
    );
  }
}

/// Repo that never completes — keeps the notifier in loading state.
/// Uses Completers so no timers are left pending after test teardown.
class _SlowRepo implements TrafficRepository {
  @override
  Future<List<String>> getDepartments() => Completer<List<String>>().future;

  @override
  Future<List<int>> getAvailableYears() => Completer<List<int>>().future;

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) =>
      Completer<int>().future;

  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(int year,
          {String? department}) =>
      Completer<Map<String, int>>().future;

  @override
  Future<Map<String, int>> getTopCitiesForYear(int year,
          {String? department}) =>
      Completer<Map<String, int>>().future;

  @override
  Future<Map<String, int>> getAccidentsBySeasonForYear(int year,
          {String? department}) =>
      Completer<Map<String, int>>().future;

  @override
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(int year,
          {String? department}) =>
      Completer<Map<String, int>>().future;

  @override
  Future<Map<String, int>> getAccidentsByWeekendForYear(int year,
          {String? department}) =>
      Completer<Map<String, int>>().future;

  @override
  Future<Map<int, int>> getAccidentsByMonthForYear(int year,
          {String? department}) =>
      Completer<Map<int, int>>().future;

  @override
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(int year,
          {String? department}) =>
      Completer<Map<String, Map<int, int>>>().future;

  @override
  Future<Map<String, int>> getAccidentsByStationForDepartment(
          int year, String department) =>
      Completer<Map<String, int>>().future;

  @override
  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword,
  }) =>
      Completer<List<AccidentModel>>().future;
}

/// Repo that always throws — puts the notifier in error state.
class _FailingRepo implements TrafficRepository {
  @override
  Future<List<String>> getDepartments() async =>
      throw Exception('Database unavailable');

  @override
  Future<List<int>> getAvailableYears() async =>
      throw Exception('Database unavailable');

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(int year,
          {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<String, int>> getTopCitiesForYear(int year,
          {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<String, int>> getAccidentsBySeasonForYear(int year,
          {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(int year,
          {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<String, int>> getAccidentsByWeekendForYear(int year,
          {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<int, int>> getAccidentsByMonthForYear(int year,
          {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(int year,
          {String? department}) async =>
      throw Exception('Database unavailable');

  @override
  Future<Map<String, int>> getAccidentsByStationForDepartment(
          int year, String department) async =>
      throw Exception('Database unavailable');

  @override
  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword,
  }) async =>
      throw Exception('Database unavailable');
}

/// Repo returning realistic sample data for all dashboard queries.
class _FakeRepo implements TrafficRepository {
  @override
  Future<List<String>> getDepartments() async =>
      ['PU Beograd', 'PU Novi Sad'];

  @override
  Future<List<int>> getAvailableYears() async => [2023, 2022];

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async {
    if (year == 2023) return 1500;
    return 1600; // prev year for delta calculation
  }

  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(int year,
      {String? department}) async {
    if (year == 2023) {
      return {
        AccidentTypes.fatalities: 50,
        AccidentTypes.injuries: 400,
        AccidentTypes.materialDamage: 1050,
      };
    }
    return {
      AccidentTypes.fatalities: 60,
      AccidentTypes.injuries: 450,
      AccidentTypes.materialDamage: 1090,
    };
  }

  @override
  Future<Map<String, int>> getTopCitiesForYear(int year,
          {String? department}) async =>
      {'Beograd': 500, 'Novi Sad': 200};

  @override
  Future<Map<String, int>> getAccidentsBySeasonForYear(int year,
          {String? department}) async =>
      {'Proleće': 400, 'Leto': 450, 'Jesen': 350, 'Zima': 300};

  @override
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(int year,
          {String? department}) async =>
      {'Jutro': 300, 'Podne': 500, 'Veče': 400, 'Noć': 300};

  @override
  Future<Map<String, int>> getAccidentsByWeekendForYear(int year,
          {String? department}) async =>
      {'Radni dan': 1100, 'Vikend': 400};

  @override
  Future<Map<int, int>> getAccidentsByMonthForYear(int year,
          {String? department}) async =>
      {
        1: 120,
        2: 110,
        3: 130,
        4: 125,
        5: 140,
        6: 150,
        7: 135,
        8: 130,
        9: 120,
        10: 115,
        11: 110,
        12: 115,
      };

  @override
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(int year,
          {String? department}) async =>
      {
        AccidentTypes.fatalities: {
          1: 4, 2: 3, 3: 5, 4: 4, 5: 5, 6: 6,
          7: 5, 8: 4, 9: 3, 10: 4, 11: 3, 12: 4,
        },
        AccidentTypes.injuries: {
          1: 30, 2: 28, 3: 35, 4: 33, 5: 38, 6: 40,
          7: 36, 8: 34, 9: 30, 10: 32, 11: 30, 12: 34,
        },
        AccidentTypes.materialDamage: {
          1: 86, 2: 79, 3: 90, 4: 88, 5: 97, 6: 104,
          7: 94, 8: 92, 9: 87, 10: 79, 11: 77, 12: 77,
        },
      };

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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saobracajke/core/di/repository_providers.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/domain/repositories/traffic_repository.dart';
import 'package:saobracajke/presentation/ui/screens/map_screen.dart';

void main() {
  group('MapScreen accident list error state', () {
    testWidgets('shows error message and retry when accident list fails to load',
        (WidgetTester tester) async {
      final fakeRepo = _FakeRepoGetAccidentsAlwaysThrows();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            home: const MapScreen(),
          ),
        ),
      );

      await _waitForAccidentsToSettle(tester);

      expect(find.text('Nije moguće učitati listu nesreća.'), findsOneWidget);
      expect(find.text('Pokušaj ponovo'), findsOneWidget);
    });

    testWidgets('retry button triggers reload',
        (WidgetTester tester) async {
      final fakeRepo = _FakeRepoGetAccidentsAlwaysThrows();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            home: const MapScreen(),
          ),
        ),
      );

      await _waitForAccidentsToSettle(tester);
      expect(find.text('Nije moguće učitati listu nesreća.'), findsOneWidget);

      await tester.tap(find.text('Pokušaj ponovo'));
      await _waitForAccidentsToSettle(tester);
      expect(find.text('Nije moguće učitati listu nesreća.'), findsOneWidget);
    });
  });
}

Future<void> _waitForAccidentsToSettle(WidgetTester tester) async {
  for (var i = 0; i < 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
  }
}

class _FakeRepoGetAccidentsAlwaysThrows implements TrafficRepository {
  @override
  Future<List<String>> getDepartments() async => ['Dept1'];

  @override
  Future<List<int>> getAvailableYears() async => [2023];

  @override
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async =>
      10;

  @override
  Future<Map<String, int>> getAccidentTypeCountsForYear(
    int year, {
    String? department,
  }) async =>
      {'Sa povredjenim': 5};

  @override
  Future<Map<String, int>> getTopCitiesForYear(
    int year, {
    String? department,
  }) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsBySeasonForYear(
    int year, {
    String? department,
  }) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(
    int year, {
    String? department,
  }) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsByWeekendForYear(
    int year, {
    String? department,
  }) async =>
      {};

  @override
  Future<Map<int, int>> getAccidentsByMonthForYear(
    int year, {
    String? department,
  }) async =>
      {};

  @override
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(
    int year, {
    String? department,
  }) async =>
      {};

  @override
  Future<Map<String, int>> getAccidentsByStationForDepartment(
    int year,
    String department,
  ) async =>
      {};

  @override
  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword,
  }) async {
    throw Exception('Load failed');
  }
}

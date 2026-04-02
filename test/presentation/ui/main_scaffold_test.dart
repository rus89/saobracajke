// ABOUTME: Widget tests for MainScaffold bottom navigation bar.
// ABOUTME: Verifies all three tabs are present and navigable.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/di/repository_providers.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/domain/repositories/traffic_repository.dart';
import 'package:saobracajke/presentation/ui/main_scaffold.dart';

void main() {
  group('MainScaffold', () {
    Widget buildSubject() {
      return ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(_SlowRepo())],
        child: const MaterialApp(home: MainScaffold()),
      );
    }

    testWidgets('shows three bottom navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Pregled'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('O aplikaciji'), findsOneWidget);
    });

    testWidgets('about tab shows about screen', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(find.text('O aplikaciji'));
      await tester.pump();

      // The about screen should show the app name
      expect(find.text('Saobraćajne Nezgode'), findsOneWidget);
    });
  });
}

/// Repo that never completes — keeps the notifier in loading state.
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

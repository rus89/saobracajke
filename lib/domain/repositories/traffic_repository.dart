import '../models/accident_model.dart';

/// Contract for traffic/accident data access.
/// Presentation and business logic depend on this interface;
/// the concrete implementation lives in the data layer.
abstract class TrafficRepository {
  Future<List<String>> getDepartments();

  Future<List<int>> getAvailableYears();

  Future<int> getTotalAccidentsForYear(int year, {String? department});

  Future<Map<String, int>> getAccidentTypeCountsForYear(
    int year, {
    String? department,
  });

  Future<Map<String, int>> getTopCitiesForYear(
    int year, {
    String? department,
  });

  Future<Map<String, int>> getAccidentsBySeasonForYear(
    int year, {
    String? department,
  });

  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(
    int year, {
    String? department,
  });

  Future<Map<String, int>> getAccidentsByWeekendForYear(
    int year, {
    String? department,
  });

  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword,
  });

  Future<Map<int, int>> getAccidentsByMonthForYear(
    int year, {
    String? department,
  });

  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(
    int year, {
    String? department,
  });

  Future<Map<String, int>> getAccidentsByStationForDepartment(
    int year,
    String department,
  );
}

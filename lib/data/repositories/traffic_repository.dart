import 'package:sqflite/sqflite.dart';

import '../../core/services/database_service.dart';
import '../../domain/accident_types.dart';
import '../../domain/models/accident_model.dart';

class TrafficRepository {
  final Future<Database> Function()? _databaseProvider;
  final DatabaseService _dbService = DatabaseService();

  TrafficRepository({Future<Database> Function()? databaseProvider})
    : _databaseProvider = databaseProvider;

  Future<Database> get _db async =>
      _databaseProvider != null ? _databaseProvider() : _dbService.database;

  // Fetch unique filter options for Dropdowns
  Future<List<String>> getDepartments() async {
    final db = await _db;
    final res = await db.query('departments', orderBy: 'name ASC');
    return res.map((e) => e['name'] as String).toList();
  }

  // Get available years
  Future<List<int>> getAvailableYears() async {
    final db = await _db;
    final res = await db.rawQuery(
      "SELECT DISTINCT strftime('%Y', date_and_time) as year FROM accidents ORDER BY year DESC",
    );
    return res.map((e) => int.parse(e['year'] as String)).toList();
  }

  // AGGREGATE: Get total accidents for a year (with optional department filter)
  Future<int> getTotalAccidentsForYear(int year, {String? department}) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    if (department != null && department.isNotEmpty) {
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
      SELECT COUNT(*) as cnt
      FROM accidents a
      JOIN departments d ON a.department_id = d.id
      WHERE $whereClause
    ''';

    final result = await db.rawQuery(sql, args);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // AGGREGATE: Get accident counts by type for a year
  Future<Map<String, int>> getAccidentTypeCountsForYear(
    int year, {
    String? department,
  }) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    if (department != null && department.isNotEmpty) {
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
      SELECT t.name, COUNT(*) as cnt
      FROM accidents a
      JOIN types t ON a.type_id = t.id
      JOIN departments d ON a.department_id = d.id
      WHERE $whereClause
      GROUP BY t.name
      ORDER BY cnt DESC
    ''';

    final result = await db.rawQuery(sql, args);
    final raw = Map.fromEntries(
      result.map((row) => MapEntry(row['name'] as String, row['cnt'] as int)),
    );
    return AccidentTypes.normalizeCounts(raw);
  }

  // AGGREGATE: Get top 10 cities/stations for a year
  Future<Map<String, int>> getTopCitiesForYear(
    int year, {
    String? department,
  }) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    if (department != null && department.isNotEmpty) {
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
      SELECT s.name, COUNT(*) as cnt
      FROM accidents a
      JOIN stations s ON a.station_id = s.id
      JOIN departments d ON a.department_id = d.id
      WHERE $whereClause
      GROUP BY s.name
      ORDER BY cnt DESC
      LIMIT 10
    ''';

    final result = await db.rawQuery(sql, args);
    return Map.fromEntries(
      result.map((row) => MapEntry(row['name'] as String, row['cnt'] as int)),
    );
  }

  // AGGREGATE: Get accidents by season for a year
  Future<Map<String, int>> getAccidentsBySeasonForYear(
    int year, {
    String? department,
  }) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    String deptJoin = '';
    if (department != null && department.isNotEmpty) {
      deptJoin = 'JOIN departments d ON a.department_id = d.id';
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
      SELECT season, COUNT(*) as cnt FROM (
        SELECT 
          CASE
            WHEN CAST(strftime('%m', a.date_and_time) AS INTEGER) BETWEEN 3 AND 5 THEN 'Proleće'
            WHEN CAST(strftime('%m', a.date_and_time) AS INTEGER) BETWEEN 6 AND 8 THEN 'Leto'
            WHEN CAST(strftime('%m', a.date_and_time) AS INTEGER) BETWEEN 9 AND 11 THEN 'Jesen'
            ELSE 'Zima'
          END AS season
        FROM accidents a
        $deptJoin
        WHERE $whereClause
      )
      GROUP BY season
    ''';

    final result = await db.rawQuery(sql, args);
    return Map.fromEntries(
      result.map((row) => MapEntry(row['season'] as String, row['cnt'] as int)),
    );
  }

  // AGGREGATE: Get accidents by time of day for a year
  Future<Map<String, int>> getAccidentsByTimeOfDayForYear(
    int year, {
    String? department,
  }) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    String deptJoin = '';
    if (department != null && department.isNotEmpty) {
      deptJoin = 'JOIN departments d ON a.department_id = d.id';
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
      SELECT time_period, COUNT(*) as cnt FROM (
        SELECT 
          CASE
            WHEN CAST(strftime('%H', a.date_and_time) AS INTEGER) BETWEEN 0 AND 5 THEN 'Noć (00-06)'
            WHEN CAST(strftime('%H', a.date_and_time) AS INTEGER) BETWEEN 6 AND 11 THEN 'Jutro (06-12)'
            WHEN CAST(strftime('%H', a.date_and_time) AS INTEGER) BETWEEN 12 AND 17 THEN 'Popodne (12-18)'
            ELSE 'Veče (18-00)'
          END AS time_period
        FROM accidents a
        $deptJoin
        WHERE $whereClause
      )
      GROUP BY time_period
    ''';

    final result = await db.rawQuery(sql, args);
    return Map.fromEntries(
      result.map(
        (row) => MapEntry(row['time_period'] as String, row['cnt'] as int),
      ),
    );
  }

  // AGGREGATE: Get accidents by weekend/weekday for a year
  Future<Map<String, int>> getAccidentsByWeekendForYear(
    int year, {
    String? department,
  }) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    String deptJoin = '';
    if (department != null && department.isNotEmpty) {
      deptJoin = 'JOIN departments d ON a.department_id = d.id';
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
      SELECT day_type, COUNT(*) as cnt FROM (
        SELECT 
          CASE
            WHEN CAST(strftime('%w', a.date_and_time) AS INTEGER) IN (0, 6) THEN 'Vikend'
            ELSE 'Radni dan'
          END AS day_type
        FROM accidents a
        $deptJoin
        WHERE $whereClause
      )
      GROUP BY day_type
    ''';

    final result = await db.rawQuery(sql, args);
    return Map.fromEntries(
      result.map(
        (row) => MapEntry(row['day_type'] as String, row['cnt'] as int),
      ),
    );
  }

  // Keep the limited query for list/map view (NOT for dashboard)
  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword,
  }) async {
    final db = await _db;

    String whereClause = "1=1";
    List<dynamic> args = [];

    if (startDate != null && endDate != null) {
      whereClause += " AND a.date_and_time BETWEEN ? AND ?";
      args.add(startDate.toIso8601String());
      args.add(endDate.toIso8601String());
    }

    if (department != null && department.isNotEmpty) {
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    if (station != null && station.isNotEmpty) {
      whereClause += " AND s.name = ?";
      args.add(station);
    }

    if (keyword != null && keyword.isNotEmpty) {
      whereClause += " AND (a.participants LIKE ? OR a.accident_id LIKE ?)";
      args.add('%$keyword%');
      args.add('%$keyword%');
    }

    final sql =
        '''
      SELECT 
        a.accident_id, 
        a.date_and_time, 
        a.latitude, 
        a.longitude, 
        a.participants, 
        a.official_desc,
        d.name as dept_name,
        s.name as station_name,
        t.name as type_name
      FROM accidents a
      JOIN departments d ON a.department_id = d.id
      JOIN stations s ON a.station_id = s.id
      JOIN types t ON a.type_id = t.id
      WHERE $whereClause
      ORDER BY a.date_and_time DESC
      LIMIT 1000
    ''';

    final result = await db.rawQuery(sql, args);
    return result.map((row) => AccidentModel.fromSql(row)).toList();
  }

  // AGGREGATE: Get accidents by month for a year
  Future<Map<int, int>> getAccidentsByMonthForYear(
    int year, {
    String? department,
  }) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    if (department != null && department.isNotEmpty) {
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
    SELECT 
      CAST(strftime('%m', a.date_and_time) AS INTEGER) as month,
      COUNT(*) as cnt
    FROM accidents a
    JOIN departments d ON a.department_id = d.id
    WHERE $whereClause
    GROUP BY month
    ORDER BY month ASC
  ''';

    final result = await db.rawQuery(sql, args);
    final Map<int, int> monthCounts = {};

    // Initialize all months with 0
    for (int i = 1; i <= 12; i++) {
      monthCounts[i] = 0;
    }

    // Fill in actual values
    for (var row in result) {
      monthCounts[row['month'] as int] = row['cnt'] as int;
    }

    return monthCounts;
  }

  // AGGREGATE: Get accidents by type per month for a year
  Future<Map<String, Map<int, int>>> getAccidentTypesByMonthForYear(
    int year, {
    String? department,
  }) async {
    final db = await _db;

    String whereClause = "strftime('%Y', a.date_and_time) = ?";
    List<dynamic> args = [year.toString()];

    if (department != null && department.isNotEmpty) {
      whereClause += " AND d.name = ?";
      args.add(department);
    }

    final sql =
        '''
    SELECT 
      t.name,
      CAST(strftime('%m', a.date_and_time) AS INTEGER) as month,
      COUNT(*) as cnt
    FROM accidents a
    JOIN types t ON a.type_id = t.id
    JOIN departments d ON a.department_id = d.id
    WHERE $whereClause
    GROUP BY t.name, month
    ORDER BY t.name, month ASC
  ''';

    final result = await db.rawQuery(sql, args);
    final Map<String, Map<int, int>> typeMonthCounts = {};

    for (var row in result) {
      final rawName = row['name'] as String;
      final canonicalType = AccidentTypes.normalize(rawName);
      final month = row['month'] as int;
      final count = row['cnt'] as int;
      typeMonthCounts.putIfAbsent(
        canonicalType,
        () => {for (int i = 1; i <= 12; i++) i: 0},
      );
      typeMonthCounts[canonicalType]![month] =
          (typeMonthCounts[canonicalType]![month] ?? 0) + count;
    }

    return typeMonthCounts;
  }

  // AGGREGATE: Get accidents by station for a department
  Future<Map<String, int>> getAccidentsByStationForDepartment(
    int year,
    String department,
  ) async {
    final db = await _db;

    final sql = '''
    SELECT s.name, COUNT(*) as cnt
    FROM accidents a
    JOIN stations s ON a.station_id = s.id
    JOIN departments d ON a.department_id = d.id
    WHERE strftime('%Y', a.date_and_time) = ?
      AND d.name = ?
    GROUP BY s.name
    ORDER BY cnt DESC
    LIMIT 20
  ''';

    final result = await db.rawQuery(sql, [year.toString(), department]);
    return Map.fromEntries(
      result.map((row) => MapEntry(row['name'] as String, row['cnt'] as int)),
    );
  }
}

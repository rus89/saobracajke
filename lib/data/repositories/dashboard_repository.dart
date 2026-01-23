import 'package:sqflite/sqflite.dart';
import '../../core/services/database_service.dart';

class DashboardStats {
  final int totalAccidents;
  final int previousYearDelta; // Positive or Negative count
  final Map<String, int> typeCounts;
  final List<Map<String, dynamic>>
  topCities; // [{'name': 'Beograd', 'count': 500}]
  final Map<String, int> seasonalCounts;
  final Map<String, int> timeOfDayCounts;

  DashboardStats({
    required this.totalAccidents,
    required this.previousYearDelta,
    required this.typeCounts,
    required this.topCities,
    required this.seasonalCounts,
    required this.timeOfDayCounts,
  });
}

class DashboardRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<DashboardStats> getYearlyStats(int year) async {
    final db = await _dbService.database;
    final prevYear = year - 1;

    // 1. TOTALS & DELTA
    // Run parallel queries for speed
    final currentFuture = db.rawQuery(
      "SELECT count(*) as cnt FROM accidents WHERE year = ?",
      [year],
    );
    final prevFuture = db.rawQuery(
      "SELECT count(*) as cnt FROM accidents WHERE year = ?",
      [prevYear],
    );

    final results = await Future.wait([currentFuture, prevFuture]);
    final total = Sqflite.firstIntValue(results[0]) ?? 0;
    final prevTotal = Sqflite.firstIntValue(results[1]) ?? 0;
    final delta = total - prevTotal;

    // 2. ACCIDENTS BY TYPE (Section 1)
    final typeRes = await db.rawQuery(
      '''
      SELECT t.name, count(*) as cnt 
      FROM accidents a 
      JOIN types t ON a.type_id = t.id 
      WHERE a.year = ? 
      GROUP BY t.name
    ''',
      [year],
    );

    final typeCounts = {
      for (var e in typeRes) e['name'].toString(): e['cnt'] as int,
    };

    // 3. TOP 10 CITIES (Section 2)
    // We group by Department (Uprava) or Station? You asked for "Cities", usually Departments map to cities better.
    final cityRes = await db.rawQuery(
      '''
      SELECT d.name, count(*) as cnt 
      FROM accidents a 
      JOIN departments d ON a.department_id = d.id 
      WHERE a.year = ? 
      GROUP BY d.name 
      ORDER BY cnt DESC 
      LIMIT 10
    ''',
      [year],
    );

    // 4. SEASONS (Section 3)
    // 03-05 Spring, 06-08 Summer, 09-11 Autumn, 12,01,02 Winter
    final monthRes = await db.rawQuery(
      '''
      SELECT strftime('%m', date_and_time) as month, count(*) as cnt 
      FROM accidents WHERE year = ? GROUP BY month
    ''',
      [year],
    );

    final seasons = {'Proleće': 0, 'Leto': 0, 'Jesen': 0, 'Zima': 0};
    for (var row in monthRes) {
      int m = int.parse(row['month'] as String);
      int count = row['cnt'] as int;
      if (m >= 3 && m <= 5) {
        seasons['Proleće'] = (seasons['Proleće']! + count);
      } else if (m >= 6 && m <= 8) {
        seasons['Leto'] = (seasons['Leto']! + count);
      } else if (m >= 9 && m <= 11) {
        seasons['Jesen'] = (seasons['Jesen']! + count);
      } else {
        seasons['Zima'] = (seasons['Zima']! + count);
      }
    }

    // 5. TIME OF DAY (Section 3)
    // Morning (06-12), Afternoon (12-18), Evening (18-00), Night (00-06)
    final timeRes = await db.rawQuery(
      '''
      SELECT strftime('%H', date_and_time) as hour, count(*) as cnt 
      FROM accidents WHERE year = ? GROUP BY hour
    ''',
      [year],
    );

    final times = {'Jutro': 0, 'Popodne': 0, 'Veče': 0, 'Noć': 0};
    for (var row in timeRes) {
      int h = int.parse(row['hour'] as String);
      int count = row['cnt'] as int;
      if (h >= 6 && h < 12) {
        times['Jutro'] = (times['Jutro']! + count);
      } else if (h >= 12 && h < 18) {
        times['Popodne'] = (times['Popodne']! + count);
      } else if (h >= 18) {
        times['Veče'] = (times['Veče']! + count);
      } else {
        times['Noć'] = (times['Noć']! + count);
      }
    }

    return DashboardStats(
      totalAccidents: total,
      previousYearDelta: delta,
      typeCounts: typeCounts,
      topCities: List<Map<String, dynamic>>.from(cityRes),
      seasonalCounts: seasons,
      timeOfDayCounts: times,
    );
  }
}

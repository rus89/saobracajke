import '../../core/services/database_service.dart';
import '../../domain/models/accident_model.dart';

//-------------------------------------------------------------------------------
class TrafficRepository {
  final DatabaseService _dbService = DatabaseService();

  // Fetch unique filter options for Dropdowns
  Future<List<String>> getDepartments() async {
    final db = await _dbService.database;
    final res = await db.query('departments', orderBy: 'name ASC');
    return res.map((e) => e['name'] as String).toList();
  }

  // The Big Search Function
  Future<List<AccidentModel>> getAccidents({
    DateTime? startDate,
    DateTime? endDate,
    String? department,
    String? station,
    String? keyword, // For searching participants
  }) async {
    final db = await _dbService.database;

    // 1. Build the Query dynamically
    String whereClause = "1=1"; // Default true
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
      args.add('%$keyword%'); // SQL 'LIKE' syntax
      args.add('%$keyword%');
    }

    // 2. The Efficient JOIN Query
    // We limit to 500 rows initially to prevent UI freeze if user selects "All"
    // Use 'OFFSET' and 'LIMIT' for pagination if you want to be fancy later.
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
}

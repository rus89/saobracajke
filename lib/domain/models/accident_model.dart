import '../accident_types.dart';

class AccidentModel {
  // Nullable if missing

  AccidentModel({
    required this.id,
    required this.department,
    required this.station,
    required this.type,
    required this.date,
    required this.lat,
    required this.lng,
    required this.participants,
    this.officialDesc,
  });

  //-------------------------------------------------------------------------------
  factory AccidentModel.fromSql(Map<String, dynamic> map) {
    final rawType = map['type_name'] as String? ?? 'Unknown';
    return AccidentModel(
      id: map['accident_id'] as String? ?? 'Unknown',
      department: map['dept_name'] as String? ?? 'Unknown',
      station: map['station_name'] as String? ?? 'Unknown',
      type: AccidentTypes.normalize(rawType),
      date: _parseDate(map['date_and_time']),
      lat: _toDouble(map['latitude']),
      lng: _toDouble(map['longitude']),
      participants: map['participants'] as String? ?? '',
      officialDesc: map['official_desc'] as String?,
    );
  }
  final String id; // The Original ID from CSV
  final String department;
  final String station;
  final String type;
  final DateTime date;
  final double lat;
  final double lng;
  final String participants;
  final String? officialDesc;

  /// Safe coercion from SQLite (may return int or double for numeric columns).
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safe parse; fallback to epoch to avoid runtime crashes on bad data.
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.utc(1970, 1, 1);
    if (value is DateTime) return value;
    final s = value is String ? value : value.toString();
    return DateTime.tryParse(s) ?? DateTime.utc(1970, 1, 1);
  }
}

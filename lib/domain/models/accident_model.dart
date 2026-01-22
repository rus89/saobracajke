class AccidentModel {
  final String id; // The Original ID from CSV
  final String department;
  final String station;
  final String type;
  final DateTime date;
  final double lat;
  final double lng;
  final String participants;
  final String? officialDesc; // Nullable if missing

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
    return AccidentModel(
      id: map['accident_id'] as String? ?? 'Unknown',
      department: map['dept_name'] as String? ?? 'Unknown', // Result of JOIN
      station: map['station_name'] as String? ?? 'Unknown', // Result of JOIN
      type: map['type_name'] as String? ?? 'Unknown', // Result of JOIN
      date: DateTime.parse(map['date_and_time']),
      lat: map['latitude'] as double,
      lng: map['longitude'] as double,
      participants: map['participants'] as String? ?? '',
      officialDesc: map['official_desc'] as String?,
    );
  }
}

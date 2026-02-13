import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/domain/models/accident_model.dart';

void main() {
  group('AccidentModel', () {
    group('fromSql', () {
      test('parses valid SQL row into AccidentModel', () {
        final map = {
          'accident_id': 'A1',
          'dept_name': 'Dept',
          'station_name': 'Station',
          'type_name': 'Sa povredjenim',
          'date_and_time': '2023-06-15 14:30:00',
          'latitude': 44.5,
          'longitude': 20.5,
          'participants': '2',
          'official_desc': 'Desc',
        };
        final model = AccidentModel.fromSql(map);
        expect(model.id, 'A1');
        expect(model.department, 'Dept');
        expect(model.station, 'Station');
        expect(model.type, 'Sa povredjenim');
        expect(model.date, DateTime(2023, 6, 15, 14, 30, 0));
        expect(model.lat, 44.5);
        expect(model.lng, 20.5);
        expect(model.participants, '2');
        expect(model.officialDesc, 'Desc');
      });

      test('uses fallbacks for null string fields', () {
        final map = {
          'accident_id': null,
          'dept_name': null,
          'station_name': null,
          'type_name': null,
          'date_and_time': '2023-01-01 00:00:00',
          'latitude': 0.0,
          'longitude': 0.0,
          'participants': null,
          'official_desc': null,
        };
        final model = AccidentModel.fromSql(map);
        expect(model.id, 'Unknown');
        expect(model.department, 'Unknown');
        expect(model.station, 'Unknown');
        expect(model.type, 'Unknown');
        expect(model.participants, '');
        expect(model.officialDesc, isNull);
      });

      test('throws on invalid date format', () {
        final map = {
          'accident_id': 'A1',
          'dept_name': 'D',
          'station_name': 'S',
          'type_name': 'T',
          'date_and_time': 'not-a-date',
          'latitude': 0.0,
          'longitude': 0.0,
          'participants': '',
        };
        expect(() => AccidentModel.fromSql(map), throwsFormatException);
      });

      test('throws when latitude is int (SQLite may return int for numeric columns)', () {
        final map = {
          'accident_id': 'A1',
          'dept_name': 'D',
          'station_name': 'S',
          'type_name': 'T',
          'date_and_time': '2023-01-01 00:00:00',
          'latitude': 44,
          'longitude': 20.0,
          'participants': '',
        };
        expect(() => AccidentModel.fromSql(map), throwsA(isA<TypeError>()));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:saobracajke/data/repositories/traffic_repository.dart';

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE departments (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
          await database.execute('''
            CREATE TABLE stations (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
          await database.execute('''
            CREATE TABLE types (
              id INTEGER PRIMARY KEY,
              name TEXT NOT NULL
            )
          ''');
          await database.execute('''
            CREATE TABLE accidents (
              accident_id TEXT NOT NULL,
              date_and_time TEXT NOT NULL,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL,
              participants TEXT,
              official_desc TEXT,
              department_id INTEGER NOT NULL,
              station_id INTEGER NOT NULL,
              type_id INTEGER NOT NULL,
              FOREIGN KEY (department_id) REFERENCES departments(id),
              FOREIGN KEY (station_id) REFERENCES stations(id),
              FOREIGN KEY (type_id) REFERENCES types(id)
            )
          ''');
          await database.insert('departments', {'id': 1, 'name': 'Belgrade'});
          await database.insert('departments', {'id': 2, 'name': 'Novi Sad'});
          await database.insert('stations', {'id': 1, 'name': 'Center'});
          await database.insert('stations', {'id': 2, 'name': 'Suburb'});
          await database.insert('types', {'id': 1, 'name': 'Sa povredjenim'});
          await database.insert('types', {'id': 2, 'name': 'Sa mat.stetom'});
          await database.insert('accidents', {
            'accident_id': 'acc-1',
            'date_and_time': '2023-05-10 12:00:00',
            'latitude': 44.82,
            'longitude': 20.46,
            'participants': '2',
            'official_desc': 'Desc',
            'department_id': 1,
            'station_id': 1,
            'type_id': 1,
          });
          await database.insert('accidents', {
            'accident_id': 'acc-2',
            'date_and_time': '2023-06-15 08:30:00',
            'latitude': 45.0,
            'longitude': 19.0,
            'participants': '1',
            'official_desc': null,
            'department_id': 2,
            'station_id': 2,
            'type_id': 2,
          });
        },
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  TrafficRepository createRepo() {
    return TrafficRepository(
      databaseProvider: () async => db,
    );
  }

  group('TrafficRepository (in-memory DB)', () {
    test('getDepartments returns names ordered by name', () async {
      final repo = createRepo();
      final list = await repo.getDepartments();
      expect(list, ['Belgrade', 'Novi Sad']);
    });

    test('getAvailableYears returns distinct years from accidents', () async {
      final repo = createRepo();
      final years = await repo.getAvailableYears();
      expect(years, [2023]);
    });

    test('getTotalAccidentsForYear returns count for year', () async {
      final repo = createRepo();
      final total = await repo.getTotalAccidentsForYear(2023);
      expect(total, 2);
    });

    test('getTotalAccidentsForYear with department filter returns filtered count',
        () async {
      final repo = createRepo();
      final total =
          await repo.getTotalAccidentsForYear(2023, department: 'Belgrade');
      expect(total, 1);
    });

    test('getAccidentTypeCountsForYear returns type counts', () async {
      final repo = createRepo();
      final counts = await repo.getAccidentTypeCountsForYear(2023);
      expect(counts['Sa povredjenim'], 1);
      expect(counts['Sa mat.stetom'], 1);
    });

    test('getAccidents returns AccidentModels with correct mapping', () async {
      final repo = createRepo();
      final list = await repo.getAccidents(
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31, 23, 59, 59),
      );
      expect(list.length, 2);
      final first = list.firstWhere((e) => e.id == 'acc-1');
      expect(first.department, 'Belgrade');
      expect(first.station, 'Center');
      expect(first.type, 'Sa povredjenim');
      expect(first.lat, 44.82);
      expect(first.lng, 20.46);
      expect(first.participants, '2');
      expect(first.officialDesc, 'Desc');
    });
  });
}

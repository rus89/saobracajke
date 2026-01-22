import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:archive/archive.dart';

//-------------------------------------------------------------------------------
class DatabaseService {
  static const String _dbName = "serbian_traffic.db";
  static const String _zipName = "serbian_traffic.db.zip";

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  //-------------------------------------------------------------------------------
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //-------------------------------------------------------------------------------
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Check if the DB already exists on the device
    if (!await databaseExists(path)) {
      debugPrint("⏳ Database not found. extracting from asset...");

      try {
        // 1. Load the ZIP from assets
        final ByteData data = await rootBundle.load(
          join("assets", "db", _zipName),
        );
        final List<int> bytes = data.buffer.asUint8List();

        // 2. Decode the ZIP
        final Archive archive = ZipDecoder().decodeBytes(bytes);

        // 3. Extract the file
        // We assume the zip contains exactly one file named same as _dbName
        for (final file in archive) {
          if (file.name == _dbName) {
            final data = file.content as List<int>;
            await File(path).writeAsBytes(data, flush: true);
            debugPrint("✅ Database extracted to: $path");
          }
        }
      } catch (e) {
        debugPrint("❌ CRITICAL ERROR: Could not extract database: $e");
        // Handle error (maybe show a dialog to the user)
      }
    } else {
      debugPrint("✅ Database already exists.");
    }

    //-------------------------------------------------------------------------------
    return await openDatabase(
      path,
      readOnly:
          true, // Keep it read-only for safety unless you plan to add user notes
    );
  }
}

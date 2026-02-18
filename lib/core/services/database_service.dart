import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//-------------------------------------------------------------------------------
/// Thrown when database extraction or opening fails during bootstrap.
/// Callers can show a user-visible message and offer retry.
class DatabaseBootstrapException implements Exception {
  DatabaseBootstrapException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause != null ? '$message: $cause' : message;
}

//-------------------------------------------------------------------------------
class DatabaseService {
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static const String _dbName = "serbian_traffic.db";
  static const String _zipName = "serbian_traffic.db.zip";

  static final DatabaseService _instance = DatabaseService._internal();

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

    if (!await databaseExists(path)) {
      debugPrint("⏳ Database not found. Extracting from asset...");

      try {
        final ByteData data = await rootBundle.load(
          join("assets", "db", _zipName),
        );
        final List<int> bytes = data.buffer.asUint8List();
        final Archive archive = ZipDecoder().decodeBytes(bytes);

        bool extracted = false;
        for (final file in archive) {
          if (file.name == _dbName) {
            final data = file.content as List<int>;
            await File(path).writeAsBytes(data, flush: true);
            extracted = true;
            debugPrint("✅ Database extracted to: $path");
            break;
          }
        }

        if (!extracted || !await databaseExists(path)) {
          throw DatabaseBootstrapException(
            'Database asset is missing or invalid (no "$_dbName" in archive)',
          );
        }
      } catch (e, st) {
        debugPrint("❌ Database extraction failed: $e");
        debugPrint("$st");
        if (e is DatabaseBootstrapException) rethrow;
        throw DatabaseBootstrapException(
          'Could not prepare database. Please try again.',
          e,
        );
      }
    } else {
      debugPrint("✅ Database already exists.");
    }

    try {
      return await openDatabase(path, readOnly: true);
    } catch (e, st) {
      debugPrint("❌ Database open failed: $e");
      debugPrint("$st");
      throw DatabaseBootstrapException(
        'Could not open database. Please try again.',
        e,
      );
    }
  }
}

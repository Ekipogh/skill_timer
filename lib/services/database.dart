import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider _instance = DBProvider._internal();
  Database? _database;

  factory DBProvider() {
    return _instance;
  }

  DBProvider._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the database
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Define the path to the database
    String path = '${await getDatabasesPath()}skill_timer.db';

    // Open the database with version and onCreate callback
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create tables here
        await db.execute('''
          CREATE TABLE skills (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            iconPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE timer_sessions (
            id TEXT PRIMARY KEY,
            skillId TEXT,
            startTime TEXT,
            endTime TEXT,
            duration INTEGER,
            notes TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );
  }
}

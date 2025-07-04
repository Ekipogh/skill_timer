import 'package:sqflite/sqflite.dart';
import '../utils/constants.dart';

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
    String path = '${await getDatabasesPath()}/skill_timer.db';

    // Open the database with version and onCreate callback
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
        // Create tables here
        await db.execute('''
          CREATE TABLE skill_categories (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            iconPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE skills (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            iconPath TEXT,
            category TEXT,
            totalTimeSpent INTEGER DEFAULT 0, -- in seconds
            sessionsCount INTEGER DEFAULT 0,
            FOREIGN KEY (category) REFERENCES skill_categories (id)
          )
        ''');
      },
    );
  }

  static Future<void> resetDatabase() async {
    final db = await DBProvider().database;
    await db.execute('DROP TABLE IF EXISTS skill_categories');
    await db.execute('DROP TABLE IF EXISTS skills');
    // Reinitialize the database
    await DBProvider()._initDB();
  }
}

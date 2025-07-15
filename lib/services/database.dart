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

    // Open the database with version, onCreate, and onUpgrade callbacks
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  /// Initial database creation for new installations
  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables for version $version');

    // Run all migrations from version 1 to current version
    for (int i = 1; i <= version; i++) {
      await _runMigration(db, i);
    }
  }

  /// Database upgrade for existing installations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Run migrations for each version between old and new
    for (int i = oldVersion + 1; i <= newVersion; i++) {
      await _runMigration(db, i);
    }
  }

  /// Database downgrade (rarely used, but good to handle)
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('Downgrading database from version $oldVersion to $newVersion');

    // For simplicity, recreate the database on downgrade
    // In production, you might want more sophisticated handling
    await _recreateDatabase(db, newVersion);
  }

  /// Execute migration for a specific version
  Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 1:
        await _migrationV1(db);
        break;
      // Add new migrations here as you update your schema
      default:
        throw Exception('Unknown migration version: $version');
    }
  }

  /// Migration V1: Initial schema
  Future<void> _migrationV1(Database db) async {
    print('Running migration V1: Initial schema');

    // Categories table
    await db.execute('''
      CREATE TABLE skill_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        iconPath TEXT
      )
    ''');

    // Skills table
    await db.execute('''
      CREATE TABLE skills (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        iconPath TEXT,
        category TEXT NOT NULL,
        FOREIGN KEY (category) REFERENCES skill_categories (id) ON DELETE CASCADE
      )
    ''');

    // Sessions table
    await db.execute('''
      CREATE TABLE timer_sessions (
        id TEXT PRIMARY KEY,
        skillId TEXT NOT NULL,
        duration INTEGER NOT NULL,
        datePerformed TEXT NOT NULL,
        FOREIGN KEY (skillId) REFERENCES skills (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_skills_category ON skills(category)');
    await db.execute(
      'CREATE INDEX idx_timer_sessions_skillId ON timer_sessions(skillId)',
    );
    await db.execute(
      'CREATE INDEX idx_timer_sessions_date ON timer_sessions(datePerformed)',
    );
  }

  /// Recreate database (used for downgrade or reset)
  Future<void> _recreateDatabase(Database db, int version) async {
    print('Recreating database for version $version');

    // Drop all tables
    await db.execute('DROP TABLE IF EXISTS timer_sessions');
    await db.execute('DROP TABLE IF EXISTS skills');
    await db.execute('DROP TABLE IF EXISTS skill_categories');
    await db.execute('DROP TABLE IF EXISTS user_preferences');

    // Recreate for target version
    for (int i = 1; i <= version; i++) {
      await _runMigration(db, i);
    }
  }

  /// Reset database (for development/testing)
  static Future<void> resetDatabase() async {
    final dbPath = '${await getDatabasesPath()}/skill_timer.db';
    await deleteDatabase(dbPath);

    // Reset the instance
    DBProvider._instance._database = null;
  }

  /// Get database schema information (useful for debugging)
  Future<List<Map<String, dynamic>>> getSchemaInfo() async {
    final db = await database;
    return await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
  }

  /// Check if a table exists
  Future<bool> tableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  Future<int> get currentVersion async {
    final db = await database;
    return await db.getVersion();
  }

  // === DEVELOPMENT UTILITIES ===
  // These methods are designed for pre-release development

  /// Quick reset for development - nukes everything and starts fresh
  /// Use this liberally during active development!
  static Future<void> devReset({String? reason}) async {
    assert(() {
      print('🔥 DEV RESET: Nuking database and starting fresh');
      if (reason != null) print('   Reason: $reason');
      print('   This is normal during pre-release development!');
      return true;
    }());

    await resetDatabase();
  }

  /// Add sample data for development/testing
  static Future<void> addSampleData() async {
    assert(() {
      print('📝 Adding sample development data');
      return true;
    }());

    final db = await DBProvider().database;

    // Sample categories
    await db.insert('skill_categories', {
      'id': 'programming',
      'name': 'Programming',
      'description': 'Software development skills',
      'iconPath': 'code',
    });

    await db.insert('skill_categories', {
      'id': 'design',
      'name': 'Design',
      'description': 'UI/UX and graphic design',
      'iconPath': 'palette',
    });

    // Sample skills
    await db.insert('skills', {
      'id': 'flutter',
      'name': 'Flutter Development',
      'description': 'Building cross-platform apps with Flutter',
      'category': 'programming',
      'totalTimeSpent': 7200, // 2 hours
      'sessionsCount': 5,
    });

    await db.insert('skills', {
      'id': 'figma',
      'name': 'Figma Design',
      'description': 'Creating mockups and prototypes',
      'category': 'design',
      'totalTimeSpent': 3600, // 1 hour
      'sessionsCount': 3,
    });
  }

  /// Check if we're in development mode and can safely reset
  static bool get canSafelyReset {
    // Add your conditions here - version checks, build mode, etc.
    return AppConstants.appVersion.contains('dev') ||
        AppConstants.appVersion.startsWith('0.') ||
        AppConstants.databaseVersion < 2; // Before first stable release
  }

  /// Safe development reset with checks
  static Future<void> safeDevReset({String? reason}) async {
    if (!canSafelyReset) {
      print('⚠️  Cannot safely reset database in production mode');
      return;
    }

    await devReset(reason: reason);
  }
}

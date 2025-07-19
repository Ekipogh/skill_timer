import 'package:sqflite/sqflite.dart';
import '../services/database.dart';
import '../utils/constants.dart';
// Add necessary import for File class
import 'dart:io';

/// Database migration utilities and helpers
class MigrationUtils {
  /// Get migration status information
  static Future<Map<String, dynamic>> getMigrationStatus() async {
    final currentVersion = await DBProvider().currentVersion;
    final latestVersion = AppConstants.databaseVersion;

    return {
      'currentVersion': currentVersion,
      'latestVersion': latestVersion,
      'isUpToDate': currentVersion == latestVersion,
      'needsUpgrade': currentVersion < latestVersion,
      'needsDowngrade': currentVersion > latestVersion,
    };
  }

  /// Get list of tables in the database
  static Future<List<String>> getTableNames() async {
    final db = await DBProvider().database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// Get table schema information
  static Future<List<Map<String, dynamic>>> getTableSchema(
    String tableName,
  ) async {
    final db = await DBProvider().database;
    return await db.rawQuery("PRAGMA table_info($tableName)");
  }

  /// Check if a column exists in a table
  static Future<bool> columnExists(String tableName, String columnName) async {
    final schema = await getTableSchema(tableName);
    return schema.any((column) => column['name'] == columnName);
  }

  /// Get database file size
  static Future<int> getDatabaseSize() async {
    try {
      final dbPath = '${await getDatabasesPath()}/skill_timer.db';
      final fileSize = await File(dbPath).length();
      return fileSize;
    } catch (e) {
      return 0;
    }
  }

  /// Export database schema for documentation
  static Future<String> exportSchema() async {
    final tables = await getTableNames();
    final buffer = StringBuffer();

    buffer.writeln(
      '# Database Schema (Version ${await DBProvider().currentVersion})',
    );
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    for (final table in tables) {
      buffer.writeln('## Table: $table');
      final schema = await getTableSchema(table);

      buffer.writeln('| Column | Type | Not Null | Default | Primary Key |');
      buffer.writeln('|--------|------|----------|---------|-------------|');

      for (final column in schema) {
        buffer.writeln(
          '| ${column['name']} | ${column['type']} | ${column['notnull'] == 1 ? 'YES' : 'NO'} | ${column['dflt_value'] ?? 'NULL'} | ${column['pk'] == 1 ? 'YES' : 'NO'} |',
        );
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Migration best practices helper
  static void logMigrationGuidelines() {
    print('''
    📚 Database Migration Best Practices:

    1. ALWAYS increment version number for schema changes
    2. NEVER modify existing migrations - add new ones
    3. TEST migrations with real data before release
    4. BACKUP user data before major migrations
    5. Keep migrations small and focused
    6. ADD proper indexes for performance
    7. USE transactions for complex migrations
    8. DOCUMENT all schema changes
    9. CONSIDER backward compatibility
    10. TEST rollback scenarios when possible
    ''');
  }
}

/// Development/testing utilities
class DevMigrationUtils {
  /// Force database to specific version (DEVELOPMENT ONLY)
  static Future<void> forceVersion(int version) async {
    assert(() {
      print('⚠️  WARNING: Forcing database version to $version');
      print('   This should ONLY be used in development!');
      return true;
    }());

    final db = await DBProvider().database;
    await db.setVersion(version);
  }

  /// Simulate migration from version to version (TESTING ONLY)
  static Future<void> simulateMigration(int fromVersion, int toVersion) async {
    assert(() {
      print('🧪 Simulating migration from v$fromVersion to v$toVersion');
      return true;
    }());

    // First, force the database to the starting version
    await forceVersion(fromVersion);

    // Then trigger the migration by accessing database with new version
    // This would normally happen when the app starts with a higher version number
    DBProvider.resetDatabase();

    // Access database to trigger migration
    await DBProvider().database;

    final finalVersion = await DBProvider().currentVersion;
    print('✅ Migration complete. Final version: $finalVersion');
  }
}

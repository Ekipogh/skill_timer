import '../services/database.dart';
import '../utils/constants.dart';

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
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// Get table schema information
  static Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final db = await DBProvider().database;
    return await db.rawQuery("PRAGMA table_info($tableName)");
  }

  /// Check if a column exists in a table
  static Future<bool> columnExists(String tableName, String columnName) async {
    final schema = await getTableSchema(tableName);
    return schema.any((column) => column['name'] == columnName);
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

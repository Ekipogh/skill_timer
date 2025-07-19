import 'package:flutter/material.dart';
import '../services/database.dart';
import '../utils/constants.dart';

/// Development utilities for database management
/// Only shown in development builds
class DevDatabaseUtils extends StatelessWidget {
  const DevDatabaseUtils({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in development mode
    if (!AppConstants.isDevelopmentMode) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Development Tools',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Database Version: ${AppConstants.databaseVersion}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Reset Database Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _resetDatabase(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Add Sample Data Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addSampleData(context),
                icon: const Icon(Icons.data_usage),
                label: const Text('Add Sample Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Show Schema Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSchema(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('Show Schema Info'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '⚠️ These tools are only available in development mode',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            // back button
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetDatabase(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Database'),
            content: const Text(
              'This will delete ALL data and recreate the database from scratch.\n\n'
              'This is safe during development but will lose any test data you\'ve entered.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && context.mounted) {
      try {
        await DBProvider.devReset(reason: 'Manual reset from dev tools');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Database reset successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Reset failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _addSampleData(BuildContext context) async {
    try {
      await DBProvider.addSampleData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample data added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add sample data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSchema(BuildContext context) async {
    try {
      final dbProvider = DBProvider();
      final version = await dbProvider.currentVersion;
      final schema = await dbProvider.getSchemaInfo();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Database Schema (v$version)'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tables:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...schema.map(
                    (table) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text('• ${table['name']}'),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to load schema: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

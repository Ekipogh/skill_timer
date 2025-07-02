import '../models/skill_category.dart';
import '../services/database.dart';

class DataSeeder {
  static Future<void> seedSampleData() async {
    final db = await DBProvider().database;

    // Check if data already exists
    final existingData = await db.query('skill_categories');
    if (existingData.isNotEmpty) {
      return; // Data already seeded
    }

    // Sample skill categories
    final sampleCategories = [
      SkillCategory(
        id: '1',
        name: 'Programming',
        description: 'Software development and coding skills',
        iconPath: 'code',
      ),
      SkillCategory(
        id: '2',
        name: 'Languages',
        description: 'Foreign language learning and practice',
        iconPath: 'language',
      ),
      SkillCategory(
        id: '3',
        name: 'Music',
        description: 'Musical instruments and composition',
        iconPath: 'music_note',
      ),
      SkillCategory(
        id: '4',
        name: 'Art & Design',
        description: 'Drawing, painting, and creative design',
        iconPath: 'palette',
      ),
      SkillCategory(
        id: '5',
        name: 'Fitness',
        description: 'Physical exercise and health activities',
        iconPath: 'fitness_center',
      ),
    ];

    // Insert sample data
    for (final category in sampleCategories) {
      await db.insert('skill_categories', category.toMap());
    }
  }
}

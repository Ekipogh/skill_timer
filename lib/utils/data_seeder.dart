import 'package:sqflite/sqlite_api.dart';

import '../models/skill_category.dart';
import '../models/skill.dart';
import '../services/database.dart';

class DataSeeder {
  static final DBProvider _dbProvider = DBProvider();
  static Database? _cachedDatabase;

  static Future<void> seedSampleData() async {
    _cachedDatabase ??= await _dbProvider.database;
    final db = _cachedDatabase!;

    await seedCategories(db);
    await seedSkills(db);
  }

  static Future<void> seedCategories(Database db) async {
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

    // Check if categories already exist
    final existingCategories = await db.query('skill_categories');
    if (existingCategories.isNotEmpty) {
      return; // Categories already seeded
    }

    // Insert categories
    for (final category in sampleCategories) {
      await db.insert('skill_categories', category.toMap());
    }
  }

  static Future<void> seedSkills(Database db) async {
    // Sample skills
    final sampleSkills = [
      Skill(
        id: '1',
        name: 'Flutter Development',
        description: 'Building mobile apps with Flutter',
        category: '1',
        totalTimeSpent: 3600, // 1 hour in seconds
        sessionsCount: 5,
      ),
      Skill(
        id: '2',
        name: 'Spanish Language',
        description: 'Learning Spanish for travel and communication',
        category: '2',
        totalTimeSpent: 7200, // 2 hours in seconds
        sessionsCount: 10,
      ),
      Skill(
        id: '3',
        name: 'Guitar Playing',
        description: 'Practicing guitar chords and songs',
        category: '3',
        totalTimeSpent: 5400, // 1.5 hours in seconds
        sessionsCount: 8,
      ),
      Skill(
        id: '4',
        name: 'Digital Painting',
        description: 'Creating digital art using Procreate',
        category: '4',
        totalTimeSpent: 1800, // 30 minutes in seconds
        sessionsCount: 3,
      ),
    ];

    // Check if skills already exist
    final existingSkills = await db.query('skills');
    if (existingSkills.isNotEmpty) {
      return; // Skills already seeded
    }

    // Insert skills
    for (final skill in sampleSkills) {
      await db.insert('skills', skill.toMap());
    }
  }
}

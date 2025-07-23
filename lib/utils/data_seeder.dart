import 'package:skill_timer/providers/firebase_provider.dart';

import '../models/skill_category.dart';
import '../models/skill.dart';

class DataSeeder {
  static final FirebaseProvider _firebaseProvider = FirebaseProvider();


  static Future<void> seedSampleData() async {
    await seedCategories();
    await seedSkills();
  }

  static Future<void> seedCategories() async {
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
    final existingCategories = _firebaseProvider.categories;

    if (existingCategories.isNotEmpty) {
      return; // Categories already seeded
    }

    // Insert categories
    for (final category in sampleCategories) {
      await _firebaseProvider.addCategory(category.toMap());
    }
  }

  static Future<void> seedSkills() async {
    // Sample skills
    final sampleSkills = [
      Skill(
        id: '1',
        name: 'Flutter Development',
        description: 'Building mobile apps with Flutter',
        category: '1',
        totalTimeSpent: 0,
        sessionsCount: 0,
      ),
      Skill(
        id: '2',
        name: 'Spanish Language',
        description: 'Learning Spanish for travel and communication',
        category: '2',
        totalTimeSpent: 0,
        sessionsCount: 0,
      ),
      Skill(
        id: '3',
        name: 'Guitar Playing',
        description: 'Practicing guitar chords and songs',
        category: '3',
        totalTimeSpent: 0,
        sessionsCount: 0,
      ),
      Skill(
        id: '4',
        name: 'Digital Painting',
        description: 'Creating digital art using Procreate',
        category: '4',
        totalTimeSpent: 0,
        sessionsCount: 0,
      ),
    ];

    // Check if skills already exist
    final existingSkills = _firebaseProvider.skills;
    if (existingSkills.isNotEmpty) {
      return; // Skills already seeded
    }

    // Insert skills
    for (final skill in sampleSkills) {
      await _firebaseProvider.addSkill(skill.toMap());
    }
  }
}

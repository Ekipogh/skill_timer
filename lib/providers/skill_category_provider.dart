import 'package:flutter/foundation.dart';
import '../models/skill_category.dart';
import '../models/skill.dart';
import '../services/database.dart';

class SkillProvider extends ChangeNotifier {
  List<SkillCategory> _skillCategories = [];
  List<Skill> _skills = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SkillCategory> get skillCategories =>
      List.unmodifiable(_skillCategories);
  List<Skill> get skills => List.unmodifiable(_skills);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _skillCategories.isEmpty && !_isLoading;

  // Load skill categories from database
  Future<void> loadSkillCategories() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      final List<Map<String, dynamic>> maps = await db.query(
        'skill_categories',
      );

      _skillCategories = maps
          .map(
            (map) => SkillCategory(
              id: map['id'],
              name: map['name'],
              description: map['description'],
              iconPath: map['iconPath'],
            ),
          )
          .toList();

      // Also load skills when loading categories
      await loadSkills();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load skill categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new skill category
  Future<void> addSkillCategory(SkillCategory category) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.insert('skill_categories', category.toMap());

      // Add to local list and notify listeners
      _skillCategories.add(category);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add skill category: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing skill category
  Future<void> updateSkillCategory(SkillCategory category) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.update(
        'skill_categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );

      // Update local list
      final index = _skillCategories.indexWhere((sc) => sc.id == category.id);
      if (index != -1) {
        _skillCategories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update skill category: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a skill category
  Future<void> deleteSkillCategory(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.delete('skill_categories', where: 'id = ?', whereArgs: [id]);

      // Remove from local list
      _skillCategories.removeWhere((sc) => sc.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete skill category: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data from database
  Future<void> refresh() async {
    _skillCategories.clear();
    _skills.clear();
    await loadSkillCategories(); // This will also load skills
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear all data (useful for logout, etc.)
  void clear() {
    _skillCategories.clear();
    _skills.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  getSkillsForCategory(String categoryId) {
    return _skills.where((skill) => skill.category == categoryId).toList();
  }

  // Add a new skill
  Future<void> addSkill(Skill skill) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.insert('skills', skill.toJson());

      // Add to local list and notify listeners
      _skills.add(skill);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add skill: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load skills from database
  Future<void> loadSkills() async {
    // Don't set loading state here since it's called from loadSkillCategories
    try {
      final db = await DBProvider().database;
      final List<Map<String, dynamic>> maps = await db.query('skills');

      _skills = maps.map((map) => Skill.fromJson(map)).toList();
    } catch (e) {
      _setError('Failed to load skills: ${e.toString()}');
    }
  }

  // Update a skill (e.g., after timer session)
  Future<void> updateSkill(Skill skill) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.update(
        'skills',
        skill.toJson(),
        where: 'id = ?',
        whereArgs: [skill.id],
      );

      // Update local list
      final index = _skills.indexWhere((s) => s.id == skill.id);
      if (index != -1) {
        _skills[index] = skill;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update skill: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a skill
  Future<void> deleteSkill(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.delete('skills', where: 'id = ?', whereArgs: [id]);

      // Remove from local list
      _skills.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete skill: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restoreSkill(Skill skill) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.insert('skills', skill.toJson());

      // Add to local list and notify listeners
      _skills.add(skill);
      notifyListeners();
    } catch (e) {
      _setError('Failed to restore skill: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restoreSkillCategory(SkillCategory category) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.insert('skill_categories', category.toMap());

      // Add to local list and notify listeners
      _skillCategories.add(category);
      notifyListeners();
    } catch (e) {
      _setError('Failed to restore skill category: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}

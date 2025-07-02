import 'package:flutter/foundation.dart';
import '../models/skill_category.dart';
import '../services/database.dart';

class SkillCategoryProvider extends ChangeNotifier {
  List<SkillCategory> _skillCategories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SkillCategory> get skillCategories => List.unmodifiable(_skillCategories);
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
      final List<Map<String, dynamic>> maps = await db.query('skill_categories');

      _skillCategories = maps.map((map) => SkillCategory(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        iconPath: map['iconPath'],
      )).toList();

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
      await db.delete(
        'skill_categories',
        where: 'id = ?',
        whereArgs: [id],
      );

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
    await loadSkillCategories();
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
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

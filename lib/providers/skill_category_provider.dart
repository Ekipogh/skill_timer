import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:skill_timer/models/learning_session.dart';
import '../models/skill_category.dart';
import '../models/skill.dart';
import '../services/database.dart';

class SkillProvider extends ChangeNotifier {
  List<SkillCategory> _skillCategories = [];
  List<Skill> _skills = [];
  List<LearningSession> _learningSessions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SkillCategory> get skillCategories =>
      List.unmodifiable(_skillCategories);
  List<Skill> get skills => List.unmodifiable(_skills);
  List<LearningSession> get learningSessions =>
      List.unmodifiable(_learningSessions);
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
    } catch (e) {
      _setError('Failed to load skill categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load timer sessions from database
  Future<void> loadSessions() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      final List<Map<String, dynamic>> maps = await db.query('timer_sessions');

      _learningSessions = maps
          .map(
            (map) => LearningSession(
              id: map['id'],
              skillId: map['skillId'],
              duration: map['duration'],
              datePerformed: DateTime.parse(map['datePerformed']),
            ),
          )
          .toList();
    } catch (e) {
      _setError('Failed to load timer sessions: ${e.toString()}');
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
    await loadSkillCategories();
    await loadSessions();
    await loadSkills();
    notifyListeners();
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
    if (_isLoading) return; // Prevent multiple simultaneous loads
    // Don't set loading state here since it's called from loadSkillCategories
    try {
      final db = await DBProvider().database;
      final List<Map<String, dynamic>> maps = await db.query('skills');

      _skills = maps.map((map) {
        final skillId = map['id'] as String;
        final totalTimeSpent = _learningSessions
            .where((session) => session.skillId == skillId)
            .fold(0, (sum, session) => sum + session.duration);
        final sessionsCount = _learningSessions
            .where((session) => session.skillId == skillId)
            .length;

        return Skill(
          id: map['id'],
          name: map['name'],
          description: map['description'],
          category: map['category'],
          totalTimeSpent: totalTimeSpent,
          sessionsCount: sessionsCount,
        );
      }).toList();
    } catch (e) {
      _setError('Failed to load skills: ${e.toString()}');
    } finally {
      _setLoading(false);
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

  Future<void> addSession(Map<String, Object> session) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await DBProvider().database;
      await db.insert('timer_sessions', session);

      // Update the skill's total time and session count
      final skillId = session['skillId'] as String;
      final skillIndex = _skills.indexWhere((s) => s.id == skillId);
      if (skillIndex != -1) {
        final skill = _skills[skillIndex];
        final newTotalTime =
            skill.totalTimeSpent + (session['duration'] as int);
        final newSessionsCount = skill.sessionsCount + 1;

        _skills[skillIndex] = skill.copyWith(
          totalTimeSpent: newTotalTime,
          sessionsCount: newSessionsCount,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add session: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods for session filtering and analysis
  List<LearningSession> getSessionsForMonth(DateTime month) {
    return _learningSessions.where((session) {
      return session.datePerformed.year == month.year &&
          session.datePerformed.month == month.month;
    }).toList();
  }

  List<LearningSession> getSessionsForSkill(String skillId) {
    return _learningSessions.where((session) => session.skillId == skillId).toList();
  }

  List<LearningSession> getSessionsForDateRange(DateTime startDate, DateTime endDate) {
    return _learningSessions.where((session) {
      return session.datePerformed.isAfter(startDate.subtract(const Duration(days: 1))) &&
          session.datePerformed.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  int getTotalTimeForMonth(DateTime month) {
    return getSessionsForMonth(month)
        .fold(0, (sum, session) => sum + session.duration);
  }

  int getTotalSessionsForMonth(DateTime month) {
    return getSessionsForMonth(month).length;
  }

  Map<String, int> getSkillTimeBreakdownForMonth(DateTime month) {
    final sessions = getSessionsForMonth(month);
    final Map<String, int> breakdown = {};

    for (var session in sessions) {
      final skill = _skills.firstWhere(
        (s) => s.id == session.skillId,
        orElse: () => Skill(
          id: session.skillId,
          name: 'Unknown Skill',
          description: '',
          category: '',
          totalTimeSpent: 0,
          sessionsCount: 0,
        ),
      );
      breakdown[skill.name] = (breakdown[skill.name] ?? 0) + session.duration;
    }

    return breakdown;
  }
}

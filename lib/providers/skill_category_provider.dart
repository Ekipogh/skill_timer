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
  List<SkillCategory> get skillCategories => List.unmodifiable(
    _skillCategories.where((category) => !_isDebugCategory(category)),
  );
  List<Skill> get skills =>
      List.unmodifiable(_skills.where((skill) => !_isDebugSkill(skill)));
  List<LearningSession> get learningSessions =>
      List.unmodifiable(_reportableSessions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => skillCategories.isEmpty && !_isLoading;

  bool _isDebugCategory(SkillCategory category) =>
      !kDebugMode && category.name.trim().toLowerCase() == 'debug';

  bool _isDebugSkill(Skill skill) {
    if (kDebugMode) return false;
    if (skill.name.trim().toLowerCase() == 'debug') return true;

    return _skillCategories.any(
      (category) => category.id == skill.category && _isDebugCategory(category),
    );
  }

  List<LearningSession> get _reportableSessions {
    if (kDebugMode) return _learningSessions;
    final debugSkillIds = _skills.where(_isDebugSkill).map((skill) => skill.id).toSet();
    return _learningSessions
        .where((session) => !debugSkillIds.contains(session.skillId))
        .toList();
  }

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
    return skills.where((skill) => skill.category == categoryId).toList();
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
          iconPath: map['iconPath'],
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

      // update local list
      _learningSessions.add(LearningSession.fromMap(session));

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
    return _reportableSessions.where((session) {
      return session.datePerformed.year == month.year &&
          session.datePerformed.month == month.month;
    }).toList();
  }

  List<LearningSession> getSessionsForSkill(String skillId) {
    return _reportableSessions
        .where((session) => session.skillId == skillId)
        .toList();
  }

  List<LearningSession> getSessionsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final normalizedStartDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    return _reportableSessions.where((session) {
      final sessionDate = DateTime(
        session.datePerformed.year,
        session.datePerformed.month,
        session.datePerformed.day,
      );
      return sessionDate.isAtSameMomentAs(normalizedStartDate) ||
          sessionDate.isAtSameMomentAs(normalizedEndDate) ||
          (sessionDate.isAfter(normalizedStartDate) &&
              sessionDate.isBefore(normalizedEndDate));
    }).toList();
  }

  int getTotalTimeForMonth(DateTime month) {
    return getSessionsForMonth(
      month,
    ).fold(0, (sum, session) => sum + session.duration);
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

  int getTotalTime() {
    return _reportableSessions.fold(0, (sum, session) => sum + session.duration);
  }

  int getTotalSessions() {
    return _reportableSessions.length;
  }

  int getAverageSessionDuration() {
    final totalSessions = getTotalSessions();
    if (totalSessions == 0) return 0;
    return getTotalTime() ~/ totalSessions;
  }

  int getCurrentStreak() {
    if (_reportableSessions.isEmpty) return 0;

    // Sort sessions by date in descending order
    final sortedSessions = List<LearningSession>.from(_reportableSessions)
      ..sort((a, b) => b.datePerformed.compareTo(a.datePerformed));

    int streak = 1;
    DateTime lastDate = DateTime(
      sortedSessions.first.datePerformed.year,
      sortedSessions.first.datePerformed.month,
      sortedSessions.first.datePerformed.day,
    );

    for (int i = 1; i < sortedSessions.length; i++) {
      final currentDate = DateTime(
        sortedSessions[i].datePerformed.year,
        sortedSessions[i].datePerformed.month,
        sortedSessions[i].datePerformed.day,
      );

      // Check if the current session is the day before the last session
      if (lastDate.difference(currentDate).inDays == 1) {
        streak++;
        lastDate = currentDate;
      } else if (lastDate.difference(currentDate).inDays > 1) {
        break; // Streak is broken
      }
    }

    return streak;
  }

  int getTimeForPeriod(Period period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case Period.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case Period.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case Period.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case Period.thisYear:
        startDate = DateTime(now.year, 1, 1);
        break;
      case Period.allTime:
        startDate = DateTime(0);
        break;
    }

    return getSessionsForDateRange(
      startDate,
      now,
    ).fold(0, (sum, session) => sum + session.duration);
  }

  Map<String, int> getTimeBySkill({int length = 5}) {
    final Map<String, int> skillTimeMap = {};

    for (var session in _reportableSessions) {
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
      skillTimeMap[skill.name] =
          (skillTimeMap[skill.name] ?? 0) + session.duration;
    }

    final sortedSkills = skillTimeMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (length <= 0 || sortedSkills.length <= length) {
      return Map.fromEntries(sortedSkills);
    }

    final topSkills = sortedSkills.take(length).toList();
    final otherTime = sortedSkills
        .skip(length)
        .fold(0, (sum, skill) => sum + skill.value);

    return {...Map.fromEntries(topSkills), 'Other': otherTime};
  }

  Map<String, int> getTimeByCategory({int length = 5}) {
    final Map<String, int> categoryTimeMap = {};

    for (var session in _reportableSessions) {
      final skill = _skills.firstWhere(
        (s) => s.id == session.skillId,
        orElse: () => Skill(
          id: session.skillId,
          name: 'Unknown Skill',
          description: '',
          category: 'Unknown Category',
          totalTimeSpent: 0,
          sessionsCount: 0,
        ),
      );
      final category = _skillCategories.firstWhere(
        (category) => category.id == skill.category,
        orElse: () => SkillCategory(
          id: skill.category,
          name: skill.category.isEmpty ? 'Unknown Category' : skill.category,
          description: '',
          iconPath: '',
        ),
      );
      categoryTimeMap[category.name] =
          (categoryTimeMap[category.name] ?? 0) + session.duration;
    }

    final sortedCategories = categoryTimeMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (length <= 0 || sortedCategories.length <= length) {
      return Map.fromEntries(sortedCategories);
    }

    final topCategories = sortedCategories.take(length).toList();
    final otherTime = sortedCategories
        .skip(length)
        .fold(0, (sum, category) => sum + category.value);

    return {...Map.fromEntries(topCategories), 'Other': otherTime};
  }
}

enum Period { today, thisWeek, thisMonth, thisYear, allTime }

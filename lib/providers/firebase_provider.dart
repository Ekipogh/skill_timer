import 'package:flutter/foundation.dart';
import 'package:skill_timer/models/learning_session.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/models/skill_category.dart';
import 'package:skill_timer/services/firebase.dart';

class FirebaseProvider with ChangeNotifier {
  List<Skill> _skills = [];
  List<Skill> get skills => _skills;
  List<SkillCategory> _categories = [];
  List<SkillCategory> get categories => _categories;
  List<LearningSession> _sessions = [];
  List<LearningSession> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? _error;
  String? get error => _error;

  bool get isEmpty =>
      _skills.isEmpty && _categories.isEmpty && _sessions.isEmpty;

  Future<void> fetchSkills() async {
    final firestore = FirebaseService.firestore;
    _skills = await firestore
        .collection("users")
        .doc("userId")
        .collection("skills")
        .get()
        .then(
          (snapshot) =>
              snapshot.docs.map((doc) => Skill.fromMap(doc.data())).toList(),
        );
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final firestore = FirebaseService.firestore;
    _categories = await firestore
        .collection("users")
        .doc("userId")
        .collection("categories")
        .get()
        .then(
          (snapshot) => snapshot.docs
              .map((doc) => SkillCategory.fromMap(doc.data()))
              .toList(),
        );
    notifyListeners();
  }

  Future<void> fetchSessions() async {
    final firestore = FirebaseService.firestore;
    _sessions = await firestore
        .collection("users")
        .doc("userId")
        .collection("sessions")
        .get()
        .then(
          (snapshot) => snapshot.docs
              .map((doc) => LearningSession.fromMap(doc.data()))
              .toList(),
        );
    notifyListeners();
  }

  Future<void> addSkill(Map<String, dynamic> skillData) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("skills")
        .add(skillData);
    _skills.add(Skill.fromMap(skillData));
    notifyListeners();
  }

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("categories")
        .add(categoryData);
    _categories.add(SkillCategory.fromMap(categoryData));
    notifyListeners();
  }

  Future<void> addSession(Map<String, dynamic> sessionData) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("sessions")
        .add(sessionData);
    _sessions.add(LearningSession.fromMap(sessionData));
    notifyListeners();
  }

  Future<void> updateSkill(Skill skill) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("skills")
        .doc(skill.id)
        .update(skill.toMap());
    final index = _skills.indexWhere((s) => s.id == skill.id);
    if (index != -1) {
      _skills[index] = skill;
      notifyListeners();
    }
  }

  Future<void> updateCategory(SkillCategory category) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("categories")
        .doc(category.id)
        .update(category.toMap());
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  Future<void> updateSession(LearningSession session) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("sessions")
        .doc(session.id)
        .update(session.toMap());
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      notifyListeners();
    }
  }

  Future<void> deleteSkill(String skillId) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("skills")
        .doc(skillId)
        .delete();
    _skills.removeWhere((s) => s.id == skillId);
    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("categories")
        .doc(categoryId)
        .delete();
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("sessions")
        .doc(sessionId)
        .delete();
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchSkills();
    await fetchCategories();
    await fetchSessions();
    notifyListeners();
  }

  Future<void> restoreSkill(Skill skill) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("skills")
        .add(skill.toMap());
    _skills.add(skill);
    notifyListeners();
  }

  Future<void> restoreCategory(SkillCategory category) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("categories")
        .add(category.toMap());
    _categories.add(category);
    notifyListeners();
  }

  Future<void> restoreSession(LearningSession session) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("sessions")
        .add(session.toMap());
    _sessions.add(session);
    notifyListeners();
  }

  List<LearningSession> getSessionsForMonth(DateTime selectedMonth) {
    return _sessions.where((session) {
      final sessionDate = session.datePerformed;
      return sessionDate.year == selectedMonth.year &&
          sessionDate.month == selectedMonth.month;
    }).toList();
  }

  int getTotalTimeForMonth(DateTime selectedMonth) {
    return getSessionsForMonth(
      selectedMonth,
    ).fold(0, (total, session) => total + session.duration);
  }

  int getTotalSessionsForMonth(DateTime selectedMonth) {
    return getSessionsForMonth(selectedMonth).length;
  }

  Map<String, int> getSkillTimeBreakdownForMonth(DateTime selectedMonth) {
    final Map<String, int> breakdown = {};
    for (var session in getSessionsForMonth(selectedMonth)) {
      breakdown[session.skillId] ??= 0;
      breakdown[session.skillId] =
          breakdown[session.skillId]! + session.duration;
    }
    return breakdown;
  }

  List<Skill> getSkillsForCategory(String categoryId) {
    return _skills.where((skill) => skill.category == categoryId).toList();
  }
}

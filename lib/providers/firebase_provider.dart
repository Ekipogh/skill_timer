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

  Future<void> addSkill(Skill skill) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("skills")
        .add(skill.toMap());
    _skills.add(skill);
    notifyListeners();
  }

  Future<void> addCategory(SkillCategory category) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("categories")
        .add(category.toMap());
    _categories.add(category);
    notifyListeners();
  }

  Future<void> addSession(LearningSession session) async {
    final firestore = FirebaseService.firestore;
    await firestore
        .collection("users")
        .doc("userId")
        .collection("sessions")
        .add(session.toMap());
    _sessions.add(session);
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
}

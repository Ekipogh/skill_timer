import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skill_timer/utils/firebase_options.dart';

class FirebaseService {
  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: SkillTimerFirebaseOptions.currentPlatform);
  }

  // Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

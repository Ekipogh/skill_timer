import 'package:flutter/material.dart';
import 'package:skill_timer/screens/skill_timer_app.dart';
import 'package:skill_timer/services/firebase.dart';
import 'package:skill_timer/utils/data_seeder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables FIRST, before Firebase initialization
  await dotenv.load(fileName: ".env");

  // Now Firebase can access the environment variables
  await FirebaseService.initialize();

  // Seed sample data on first run
  await DataSeeder.seedSampleData();

  runApp(const SkillTimerApp());
}

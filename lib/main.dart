import 'package:flutter/material.dart';
import 'package:skill_timer/screens/skill_timer_app.dart';
import 'package:skill_timer/services/firebase.dart';
import 'package:skill_timer/utils/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  // Seed sample data on first run
  await DataSeeder.seedSampleData();

  runApp(const SkillTimerApp());
}

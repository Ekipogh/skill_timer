import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:skill_timer/screens/skill_timer_app.dart';
import 'package:skill_timer/utils/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();

  // Seed sample data on first run
  await DataSeeder.seedSampleData();

  runApp(const SkillTimerApp());
}

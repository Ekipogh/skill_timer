import 'package:flutter/material.dart';
import 'package:skill_timer/screens/skill_timer_app.dart';
import 'package:skill_timer/services/database.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = await DBProvider().database;
  runApp(const SkillTimerApp());
}

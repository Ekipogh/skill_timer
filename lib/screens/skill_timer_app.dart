import 'package:flutter/material.dart';
import 'package:skill_timer/screens/homescreen.dart';

class SkillTimerApp extends StatefulWidget {
  @override
  const SkillTimerApp({super.key});
  @override
  State<SkillTimerApp> createState() => _SkillTimerAppState();
}

class _SkillTimerAppState extends State<SkillTimerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Timer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(key: const Key('home_screen')),
    );
  }
}

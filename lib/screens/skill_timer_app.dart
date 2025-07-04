import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/screens/homescreen.dart';
import 'package:skill_timer/providers/skill_category_provider.dart';
import 'package:skill_timer/utils/constants.dart';

class SkillTimerApp extends StatefulWidget {
  @override
  const SkillTimerApp({super.key});
  @override
  State<SkillTimerApp> createState() => _SkillTimerAppState();
}

class _SkillTimerAppState extends State<SkillTimerApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => SkillProvider())],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(key: const Key('home_screen')),
      ),
    );
  }
}

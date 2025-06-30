import 'package:flutter/material.dart';

class SkillTimerApp extends StatefulWidget {
  @override
  const SkillTimerApp({Key? key}) : super(key: key);
  @override
  State<SkillTimerApp> createState() => _SkillTimerAppState();
}

class _SkillTimerAppState extends State<SkillTimerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Skill Timer'),
        ),
        body: const Center(
          child: Text('Welcome to Skill Timer!'),
        ),
      ),
    );
  }
}

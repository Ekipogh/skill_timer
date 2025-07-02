// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_timer/screens/skill_timer_app.dart';
import 'package:skill_timer/screens/homescreen.dart';

void main() {
  testWidgets('Skill Timer App starts with HomeScreen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SkillTimerApp());

    // Verify that HomeScreen is displayed.
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('HomeScreen has AppBar with title', (WidgetTester tester) async {
    await tester.pumpWidget(const SkillTimerApp());

    // Verify that the AppBar has the correct title.
    expect(find.text('Skill Timer'), findsOneWidget);
  });

  testWidgets('HomeScreen has FloatingActionButton', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SkillTimerApp());

    // Verify that there is a FloatingActionButton.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

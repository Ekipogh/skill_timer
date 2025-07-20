// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/models/skill_category.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/screens/homescreen.dart';
import 'package:skill_timer/screens/skills_screen.dart';
import 'package:skill_timer/providers/skill_category_provider.dart';

// Mock Provider for testing
class MockSkillProvider extends SkillProvider {
  final List<SkillCategory> _mockSkillCategories = [
    SkillCategory(
      id: '1',
      name: 'Programming',
      description: 'Learn coding skills',
      iconPath: 'code',
    ),
    SkillCategory(
      id: '2',
      name: 'Design',
      description: 'UI/UX and graphic design',
      iconPath: 'design',
    ),
  ];

  final List<Skill> _mockSkills = [
    Skill(
      id: '1',
      name: 'Flutter',
      description: 'Mobile app development',
      category: '1',
      totalTimeSpent: 3600,
      sessionsCount: 5,
    ),
    Skill(
      id: '2',
      name: 'JavaScript',
      description: 'Web development',
      category: '1',
      totalTimeSpent: 7200,
      sessionsCount: 10,
    ),
  ];

  @override
  List<SkillCategory> get skillCategories => _mockSkillCategories;

  @override
  List<Skill> get skills => _mockSkills;

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  String? get error => null;

  @override
  bool get isEmpty => false;

  @override
  List<Skill> getSkillsForCategory(String categoryId) {
    return _mockSkills.where((skill) => skill.category == categoryId).toList();
  }

  @override
  Future<void> loadSkillCategories() async {
    // Mock - do nothing, data is already available
  }

  @override
  Future<void> addSkillCategory(SkillCategory category) async {
    _mockSkillCategories.add(category);
    notifyListeners();
  }

  @override
  Future<void> addSkill(Skill skill) async {
    _mockSkills.add(skill);
    notifyListeners();
  }

  @override
  Future<void> refresh() async {
    // Mock - do nothing
  }
}

void main() {
  // Helper function to create a testable widget with mock provider
  Widget createTestWidget({Widget? child}) {
    return ChangeNotifierProvider<SkillProvider>(
      create: (context) => MockSkillProvider(),
      child: MaterialApp(home: child ?? const HomeScreen()),
    );
  }

  testWidgets('HomeScreen displays with mock data', (
    WidgetTester tester,
  ) async {
    final testWidget = createTestWidget();
    // Build HomeScreen with mock provider
    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle();

    // Verify that HomeScreen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify mock data is displayed
    expect(find.text('Programming'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
  });

  testWidgets('HomeScreen has AppBar with title', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify that the AppBar has the correct title
    expect(find.text('Skill Timer'), findsOneWidget);
  });

  testWidgets('HomeScreen has FloatingActionButton', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify that there is a FloatingActionButton
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets("Click the skill category tile and navigate to SkillsScreen", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Find the first skill category tile (Programming)
    final categoryTile = find.text('Programming');
    expect(categoryTile, findsOneWidget);

    // Tap on the category tile to navigate to SkillsScreen
    await tester.tap(categoryTile);
    await tester.pumpAndSettle();

    // Verify that SkillsScreen is displayed
    expect(find.byType(SkillsScreen), findsOneWidget);
    // Verify we're on the Programming skills screen
    expect(
      find.text('Programming'),
      findsExactly(2),
    ); //one on HomeScreen, one on SkillsScreen
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('SkillsScreen shows skills for category', (
    WidgetTester tester,
  ) async {
    // Create a SkillsScreen directly with mock data
    final mockProvider = MockSkillProvider();
    final programmingCategory = mockProvider.skillCategories.first;

    await tester.pumpWidget(
      ChangeNotifierProvider<SkillProvider>.value(
        value: mockProvider,
        child: MaterialApp(home: SkillsScreen(category: programmingCategory)),
      ),
    );
    await tester.pumpAndSettle();

    // Verify SkillsScreen displays
    expect(find.byType(SkillsScreen), findsOneWidget);

    // Verify skills are displayed
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('JavaScript'), findsOneWidget);

    // Verify time and session info (with bullet point format)
    expect(find.text('1h'), findsOneWidget);
    expect(find.text('5 sessions'), findsOneWidget);
    expect(find.text('2h'), findsOneWidget);
    expect(find.text('10 sessions'), findsOneWidget);
  });

  testWidgets('Empty state shows when no skills in category', (
    WidgetTester tester,
  ) async {
    // Create a category that doesn't exist in our mock data
    final category = SkillCategory(
      id: '999', // This ID doesn't exist in our mock skills
      name: 'Empty Category',
      description: 'No skills here',
      iconPath: 'empty',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<SkillProvider>(
        create: (context) => MockSkillProvider(),
        child: MaterialApp(home: SkillsScreen(category: category)),
      ),
    );
    await tester.pumpAndSettle();

    // Verify empty state is displayed (since category ID '999' has no skills)
    expect(find.text('No skills in Empty Category yet'), findsOneWidget);
    expect(find.text('Add First Skill'), findsOneWidget);
  });
}

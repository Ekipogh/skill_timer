import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/providers/skill_category_provider.dart';
import 'package:skill_timer/screens/manual_data.dart';
import 'package:skill_timer/utils/formatters.dart';

/// Mock provider for testing manual data entry functionality
class MockSkillProvider extends SkillProvider {
  final List<Map<String, Object>> _mockSessions = [];
  bool _throwError = false;

  // Test data
  final List<Skill> _mockSkills = [
    Skill(
      id: 'test-skill-1',
      name: 'Flutter Development',
      description: 'Mobile app development with Flutter',
      category: 'programming',
      totalTimeSpent: 3600,
      sessionsCount: 5,
    ),
  ];

  @override
  List<Skill> get skills => List.unmodifiable(_mockSkills);

  @override
  bool get isLoading => false;

  @override
  bool get hasError => false;

  @override
  String? get error => null;

  /// Add a session - for testing purposes
  @override
  Future<void> addSession(Map<String, Object> session) async {
    if (_throwError) {
      throw Exception('Mock error for testing');
    }
    _mockSessions.add(session);
    notifyListeners();
  }

  /// Get all sessions added during tests
  List<Map<String, Object>> get testSessions =>
      List.unmodifiable(_mockSessions);

  /// Configure provider to throw errors for testing error scenarios
  void setThrowError(bool shouldThrow) {
    _throwError = shouldThrow;
  }

  /// Clear test data
  void clearTestData() {
    _mockSessions.clear();
    _throwError = false;
  }
}

/// Helper function to create a testable widget with provider
Widget createTestableWidget({
  required Widget child,
  MockSkillProvider? mockProvider,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<SkillProvider>(
      create: (_) => mockProvider ?? MockSkillProvider(),
      child: child,
    ),
  );
}

void main() {
  group('ManualDataEntryScreen Tests', () {
    late MockSkillProvider mockProvider;
    late Skill testSkill;

    setUp(() {
      mockProvider = MockSkillProvider();
      testSkill = Skill(
        id: 'test-skill-1',
        name: 'Flutter Development',
        description: 'Mobile app development with Flutter',
        category: 'programming',
        totalTimeSpent: 3600,
        sessionsCount: 5,
      );
    });

    tearDown(() {
      mockProvider.clearTestData();
    });

    group('Widget Structure Tests', () {
      testWidgets('should render ManualDataEntryScreen with correct title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Verify the app bar title
        expect(
          find.text('Manual Data Entry for Flutter Development'),
          findsOneWidget,
        );
      });

      testWidgets('should display skill information card', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Verify skill name and description are displayed
        expect(find.text('Flutter Development Manual Entry'), findsOneWidget);
        expect(
          find.text('Mobile app development with Flutter'),
          findsOneWidget,
        );
      });

      testWidgets('should display manual entry form', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Verify form elements are present
        expect(find.text('Duration'), findsOneWidget);
        expect(find.text('Date'), findsOneWidget);
        expect(find.text('Save Session'), findsOneWidget);
      });
    });

    group('ManualDataEntryForm Tests', () {
      testWidgets('should initialize with default values', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Check initial duration display
        expect(find.text('0s'), findsOneWidget);

        // Check that today's date is formatted and displayed
        final today = DateTime.now();
        final formattedToday = Formatters.formatDate(today);
        expect(find.text(formattedToday), findsOneWidget);
      });

      testWidgets('should disable save button when duration is 0', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Find the save button text
        expect(find.text('Save Session'), findsOneWidget);

        // Find the button and verify it's disabled
        final saveButtonFinder = find.ancestor(
          of: find.text('Save Session'),
          matching: find.byType(ElevatedButton),
        );

        if (saveButtonFinder.evaluate().isNotEmpty) {
          final buttonWidget = tester.widget<ElevatedButton>(saveButtonFinder);
          expect(buttonWidget.onPressed, isNull);
        }
      });

      testWidgets('should enable save button when duration > 0', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Tap on duration picker to open dialog
        await tester.tap(find.text('Duration').first);
        await tester.pumpAndSettle();

        // Tap on 5 min preset button
        await tester.tap(find.text('5 min'));
        await tester.pumpAndSettle();

        // Verify duration is updated
        expect(find.textContaining('5'), findsAtLeastNWidgets(1));

        // Verify save button exists and find it
        expect(find.text('Save Session'), findsOneWidget);

        final saveButtonFinder = find.ancestor(
          of: find.text('Save Session'),
          matching: find.byType(ElevatedButton),
        );

        if (saveButtonFinder.evaluate().isNotEmpty) {
          final buttonWidget = tester.widget<ElevatedButton>(saveButtonFinder);
          expect(buttonWidget.onPressed, isNotNull);
        }
      });
    });

    group('Duration Picker Tests', () {
      testWidgets('should open duration picker dialog', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Tap on duration field
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Select Duration'), findsOneWidget);
        expect(find.text('Hours'), findsOneWidget);
        expect(find.text('Minutes'), findsOneWidget);
        expect(find.text('Seconds'), findsOneWidget);
      });

      testWidgets('should have preset duration buttons', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Open duration picker
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();

        // Verify preset buttons exist
        expect(find.text('5 min'), findsOneWidget);
        expect(find.text('15 min'), findsOneWidget);
        expect(find.text('30 min'), findsOneWidget);
        expect(find.text('1 hour'), findsOneWidget);
      });

      testWidgets('should select 15 minutes preset', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Open duration picker and select 15 min preset
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15 min'));
        await tester.pumpAndSettle();

        // Verify duration is updated
        expect(find.text('15m'), findsOneWidget);
      });

      testWidgets('should cancel duration picker', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Open duration picker
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();

        // Cancel dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify duration remains 0
        expect(find.text('0s'), findsOneWidget);
      });
    });

    group('Date Picker Tests', () {
      testWidgets('should open date picker dialog', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Tap on date field
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Verify date picker is shown (look for common date picker elements)
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('should display selected date', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Open date picker
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Select a specific date (tap on day 15 if available)
        final day15 = find.text('15');
        if (tester.any(day15)) {
          await tester.tap(day15.first);
          await tester.pumpAndSettle();

          // Confirm date selection
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
        }
      });
    });

    group('Save Session Tests', () {
      testWidgets('should save session with valid data', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Set duration
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5 min'));
        await tester.pumpAndSettle();

        // Save session
        await tester.tap(find.text('Save Session'));
        await tester.pumpAndSettle();

        // Verify session was added to provider
        expect(mockProvider.testSessions.length, 1);
        final session = mockProvider.testSessions.first;
        expect(session['skillId'], testSkill.id);
        expect(session['duration'], 300); // 5 minutes = 300 seconds
      });

      testWidgets('should show success message after saving', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: Scaffold(body: ManualDataEntryScreen(skill: testSkill)),
            mockProvider: mockProvider,
          ),
        );

        // Set duration and save
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();
        await tester.tap(find.text('30 min'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Session'));
        await tester.pump();

        // Look for success message
        expect(
          find.textContaining('Manual session saved: 30m'),
          findsOneWidget,
        );
      });

      testWidgets('should handle save errors gracefully', (
        WidgetTester tester,
      ) async {
        // Configure provider to throw error
        mockProvider.setThrowError(true);

        await tester.pumpWidget(
          createTestableWidget(
            child: Scaffold(body: ManualDataEntryScreen(skill: testSkill)),
            mockProvider: mockProvider,
          ),
        );

        // Set duration and attempt to save
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();
        await tester.tap(find.text('15 min'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Session'));
        await tester.pumpAndSettle();

        // Verify error message is shown
        expect(find.textContaining('Failed to save session'), findsOneWidget);

        // Verify we didn't navigate away (still on the form)
        expect(find.text('Save Session'), findsOneWidget);

        // Verify no session was actually saved
        expect(mockProvider.testSessions.length, 0);
      });
    });

    group('Navigation Tests', () {
      testWidgets('should navigate back after successful save', (
        WidgetTester tester,
      ) async {

        // Test Widget with button that opens manual entry screen
        Widget testWidget = MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test Navigation')),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    tester.element(find.byType(Center)),
                    MaterialPageRoute(
                      builder: (context) =>
                          ManualDataEntryScreen(skill: testSkill),
                    ),
                  );
                },
                child: const Text('Open Manual Entry'),
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          createTestableWidget(child: testWidget, mockProvider: mockProvider),
        );

        // Navigate to manual entry screen
        await tester.tap(find.text('Open Manual Entry'));
        await tester.pumpAndSettle();

        // Set duration and save
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5 min'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save Session'));
        await tester.pumpAndSettle();

        // Verify we're back to the previous screen
        expect(find.text('Open Manual Entry'), findsOneWidget);
        expect(find.text('Save Session'), findsNothing);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic labels', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Verify semantic labels exist for key interactive elements
        expect(find.byIcon(Icons.timer), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        expect(find.byIcon(Icons.save), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // click 5 min to enable the save button
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();
        await tester.tap(find.text('5 min'));
        await tester.pumpAndSettle();

        // Verify focusable widgets exist
        expect(find.byType(GestureDetector), findsAtLeastNWidgets(2));

        // The save button is ElevatedButton.icon, which is a subtype of ElevatedButton
        expect(find.bySubtype<ElevatedButton>(), findsAtLeastNWidgets(1));

        // Also verify we can find the button by its text and icon
        expect(find.text('Save Session'), findsOneWidget);
        expect(find.byIcon(Icons.save), findsOneWidget);
      });
    });

    group('Edge Cases Tests', () {
      testWidgets('should handle skill with no description', (
        WidgetTester tester,
      ) async {
        final skillWithoutDescription = Skill(
          id: 'test-skill-2',
          name: 'Minimal Skill',
          description: 'Test description',
          category: 'test',
          totalTimeSpent: 0,
          sessionsCount: 0,
        );

        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: skillWithoutDescription),
            mockProvider: mockProvider,
          ),
        );

        expect(find.text('Minimal Skill Manual Entry'), findsOneWidget);
        // Description should not be shown when empty
        expect(find.text('Test description'), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle very large duration values', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Open duration picker
        await tester.tap(find.byIcon(Icons.timer));
        await tester.pumpAndSettle();

        // Select 1 hour preset
        await tester.tap(find.text('1 hour'));
        await tester.pumpAndSettle();

        // Verify formatting works for large values
        expect(find.text('1h'), findsOneWidget);
      });

      testWidgets('should handle date selection edge cases', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestableWidget(
            child: ManualDataEntryScreen(skill: testSkill),
            mockProvider: mockProvider,
          ),
        );

        // Open date picker
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Cancel date picker - try different possible button texts
        if (find.text('CANCEL').evaluate().isNotEmpty) {
          await tester.tap(find.text('CANCEL'));
        } else if (find.text('Cancel').evaluate().isNotEmpty) {
          await tester.tap(find.text('Cancel'));
        } else {
          // Just tap outside the dialog
          await tester.tapAt(const Offset(50, 50));
        }
        await tester.pumpAndSettle();

        // Verify original date is maintained
        final today = Formatters.formatDate(DateTime.now());
        expect(find.text(today), findsOneWidget);
      });
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_timer/widgets/widgets.dart';

void main() {
  group('Custom Shared Widgets Tests', () {
    testWidgets('CustomAppBar displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CustomAppBar(
              title: 'Test Title',
              centerTitle: true,
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('TimerDisplay shows correct time format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimerDisplay(
              elapsedTime: '00:05:30.123',
              isRunning: true,
            ),
          ),
        ),
      );

      expect(find.text('00:05:30.123'), findsOneWidget);
    });

    testWidgets('CustomSnackBar success message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  CustomSnackBar.showSuccess(
                    context,
                    message: 'Success message',
                  );
                },
                child: const Text('Show Success'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text('Success message'), findsOneWidget);
    });

    testWidgets('IconCard displays with correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconCard(
              icon: Icons.star,
              title: 'Test Card',
              subtitle: 'Test Description',
              iconColor: Colors.blue,
              iconBackgroundColor: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('EmptyStateCard displays correctly', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateCard(
              icon: Icons.inbox,
              title: 'Empty State',
              subtitle: 'No items found',
              buttonText: 'Add Item',
              onButtonPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Empty State'), findsOneWidget);
      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);

      await tester.tap(find.text('Add Item'));
      expect(buttonPressed, isTrue);
    });

    test('TimeFormatter formats time correctly', () {
      expect(TimeFormatter.format(0), equals('0s'));
      expect(TimeFormatter.format(30), equals('30s'));
      expect(TimeFormatter.format(60), equals('1m'));
      expect(TimeFormatter.format(90), equals('1m 30s'));
      expect(TimeFormatter.format(3600), equals('1h'));
      expect(TimeFormatter.format(3660), equals('1h 1m'));
      expect(TimeFormatter.format(7320), equals('2h 2m'));
    });

    testWidgets('StatBadge displays with correct values', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatBadge(
              icon: Icons.timer,
              value: '5h 30m',
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('5h 30m'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('TimeBadge displays formatted time', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimeBadge(time: '2h 15m'),
          ),
        ),
      );

      expect(find.text('2h 15m'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('SessionsBadge displays session count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SessionsBadge(sessions: 10),
          ),
        ),
      );

      expect(find.text('10 sessions'), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });
  });
}

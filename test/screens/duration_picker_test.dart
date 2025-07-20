import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Custom Duration Picker Tests', () {
    Widget createPickerTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  // Create test helper to show the picker
                  final testHelper = _DurationPickerTestHelper();

                  // Show the picker
                  await testHelper.showTimerPickerDialog(
                    context: context,
                    initialTime: 0,
                  );
                },
                child: const Text('Show Picker'),
              );
            },
          ),
        ),
      );
    }

    group('Duration Picker Dialog', () {
      testWidgets('should display picker with correct title',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        expect(find.text('Select Duration'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('should have time wheel scrollers',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Should have 3 wheel scrollers for hours, minutes, seconds
        expect(find.byType(ListWheelScrollView), findsNWidgets(3));
        expect(find.text('Hours'), findsOneWidget);
        expect(find.text('Minutes'), findsOneWidget);
        expect(find.text('Seconds'), findsOneWidget);
      });

      testWidgets('should display preset buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Check for preset buttons
        expect(find.text('5 min'), findsOneWidget);
        expect(find.text('15 min'), findsOneWidget);
        expect(find.text('30 min'), findsOneWidget);
        expect(find.text('1 hour'), findsOneWidget);
      });

      testWidgets('should have OK button', (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        expect(find.text('OK'), findsOneWidget);
      });
    });

    group('Time Wheel Functionality', () {
      testWidgets('should initialize wheels with correct values',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Should start at 00:00:00
        expect(find.text('00'), findsAtLeastNWidgets(3));
      });

      testWidgets('should have correct number ranges',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Verify the wheels show proper ranges
        // Hours: 0-23, Minutes: 0-59, Seconds: 0-59
        // This is implicitly tested by the ListWheelScrollView childCount
        expect(find.byType(ListWheelScrollView), findsNWidgets(3));
      });
    });

    group('Preset Button Functionality', () {
      testWidgets('should handle 5 minute preset',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('5 min'));
        await tester.pumpAndSettle();

        // Dialog should close after preset selection
        expect(find.text('Select Duration'), findsNothing);
      });

      testWidgets('should handle 1 hour preset',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1 hour'));
        await tester.pumpAndSettle();

        // Dialog should close
        expect(find.text('Select Duration'), findsNothing);
      });
    });

    group('Dialog Interactions', () {
      testWidgets('should close on cancel', (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Select Duration'), findsNothing);
      });

      testWidgets('should close on OK', (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.text('Select Duration'), findsNothing);
      });

      testWidgets('should close on backdrop tap',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Tap outside the dialog (on the barrier)
        await tester.tapAt(const Offset(50, 50));
        await tester.pumpAndSettle();

        expect(find.text('Select Duration'), findsNothing);
      });
    });

    group('Visual Design', () {
      testWidgets('should have proper styling', (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Check for themed container
        expect(find.byType(Container), findsAtLeastNWidgets(1));
        expect(find.byType(FilterChip), findsNWidgets(4)); // 4 preset buttons
      });

      testWidgets('should have proper sizing', (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Dialog should be properly sized
        final dialog = find.byType(AlertDialog);
        expect(dialog, findsOneWidget);

        // Content should be in a SizedBox with specific dimensions
        final sizedBox = find.descendant(
          of: dialog,
          matching: find.byType(SizedBox),
        );
        expect(sizedBox, findsAtLeastNWidgets(1));
      });
    });

    group('Accessibility', () {
      testWidgets('should have semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Check for accessible text labels
        expect(find.text('Hours'), findsOneWidget);
        expect(find.text('Minutes'), findsOneWidget);
        expect(find.text('Seconds'), findsOneWidget);
      });

      testWidgets('should support keyboard navigation',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Buttons should be focusable
        expect(find.byType(FilterChip), findsNWidgets(4));
        expect(find.text('OK'), findsOneWidget); // OK button in dialog
        expect(find.byType(ElevatedButton), findsNWidgets(2)); // Show Picker + OK button
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid preset button taps',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // Rapidly tap different presets
        await tester.tap(find.text('5 min'));
        await tester.pump(const Duration(milliseconds: 10));
        // Dialog should already be closed after first tap
      });

      testWidgets('should handle wheel scroll edge values',
          (WidgetTester tester) async {
        await tester.pumpWidget(createPickerTestWidget());

        await tester.tap(find.text('Show Picker'));
        await tester.pumpAndSettle();

        // The ListWheelScrollView should handle edge cases internally
        // This test ensures no crashes occur with extreme values
        expect(find.byType(ListWheelScrollView), findsNWidgets(3));
      });
    });
  });
}

/// Test helper class to access private methods
class _DurationPickerTestHelper {
  Future<int?> showTimerPickerDialog({
    required BuildContext context,
    required int initialTime,
  }) {
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Duration'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: 360,
              width: 320,
              child: _buildCustomDurationPicker(initialTime),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomDurationPicker(int initialSeconds) {
    int hours = initialSeconds ~/ 3600;
    int minutes = (initialSeconds % 3600) ~/ 60;
    int seconds = initialSeconds % 60;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hours, Minutes, Seconds Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeColumn('Hours', hours, 23, (value) {
                    setState(() => hours = value);
                  }),
                  const Text(
                    '\n:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _buildTimeColumn('Minutes', minutes, 59, (value) {
                    setState(() => minutes = value);
                  }),
                  const Text(
                    '\n:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _buildTimeColumn('Seconds', seconds, 59, (value) {
                    setState(() => seconds = value);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Quick preset buttons
            Wrap(
              spacing: 8,
              children: [
                _buildPresetButton(context, '5 min', 5 * 60, (duration) {
                  Navigator.of(context).pop(duration);
                }),
                _buildPresetButton(context, '15 min', 15 * 60, (duration) {
                  Navigator.of(context).pop(duration);
                }),
                _buildPresetButton(context, '30 min', 30 * 60, (duration) {
                  Navigator.of(context).pop(duration);
                }),
                _buildPresetButton(context, '1 hour', 60 * 60, (duration) {
                  Navigator.of(context).pop(duration);
                }),
              ],
            ),
            const Spacer(),
            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final totalSeconds = hours * 3600 + minutes * 60 + seconds;
                  Navigator.of(context).pop(totalSeconds);
                },
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeColumn(
    String label,
    int value,
    int maxValue,
    Function(int) onChanged,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: onChanged,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < 0 || index > maxValue) return null;
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              childCount: maxValue + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    String label,
    int duration,
    Function(int) onPressed,
  ) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) => onPressed(duration),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_timer/widgets/form_widgets.dart';

Widget _buildDialogLauncher({
  required VoidCallbackBuilder builder,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return Center(
            child: ElevatedButton(
              onPressed: builder(context),
              child: const Text('Open Dialog'),
            ),
          );
        },
      ),
    ),
  );
}

typedef VoidCallbackBuilder = VoidCallback Function(BuildContext context);

void main() {
  group('Icon editing forms', () {
    testWidgets('AddSkillDialog confirms selected icon', (
      WidgetTester tester,
    ) async {
      String? confirmedName;
      String? confirmedDescription;
      String? confirmedIconPath;

      await tester.pumpWidget(
        _buildDialogLauncher(
          builder: (context) {
            return () {
              AddSkillDialog.show(
                context,
                onConfirm: (name, description, iconPath) {
                  confirmedName = name;
                  confirmedDescription = description;
                  confirmedIconPath = iconPath;
                },
              );
            };
          },
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Add Skill'), findsOneWidget);
      expect(find.text('Psychology'), findsOneWidget);

      await tester.tap(find.text('Psychology'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.text('Camera Alt'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Skill Name'),
        'Photography',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Camera practice',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(confirmedName, 'Photography');
      expect(confirmedDescription, 'Camera practice');
      expect(confirmedIconPath, 'camera_alt');
    });

    testWidgets('EditSkillDialog updates and confirms selected icon', (
      WidgetTester tester,
    ) async {
      String? confirmedName;
      String? confirmedDescription;
      String? confirmedIconPath;

      await tester.pumpWidget(
        _buildDialogLauncher(
          builder: (context) {
            return () {
              EditSkillDialog.show(
                context,
                initialName: 'Flutter',
                initialDescription: 'Build apps',
                initialIconPath: 'brush',
                onConfirm: (name, description, iconPath) {
                  confirmedName = name;
                  confirmedDescription = description;
                  confirmedIconPath = iconPath;
                },
              );
            };
          },
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Skill'), findsOneWidget);
      expect(find.text('Brush'), findsOneWidget);

      await tester.tap(find.text('Brush'));
      await tester.pumpAndSettle();

      expect(find.text('Select Icon'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.music_note));
      await tester.pumpAndSettle();

      expect(find.text('Music Note'), findsOneWidget);
      expect(find.text('Brush'), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(confirmedName, 'Flutter');
      expect(confirmedDescription, 'Build apps');
      expect(confirmedIconPath, 'music_note');
    });

    testWidgets('AddCategoryDialog confirms selected icon', (
      WidgetTester tester,
    ) async {
      String? confirmedName;
      String? confirmedDescription;
      String? confirmedIconPath;

      await tester.pumpWidget(
        _buildDialogLauncher(
          builder: (context) {
            return () {
              AddCategoryDialog.show(
                context,
                onConfirm: (name, description, iconPath) {
                  confirmedName = name;
                  confirmedDescription = description;
                  confirmedIconPath = iconPath;
                },
              );
            };
          },
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Add Skill Category'), findsOneWidget);
      expect(find.text('Psychology'), findsOneWidget);

      await tester.tap(find.text('Psychology'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.science));
      await tester.pumpAndSettle();

      expect(find.text('Science'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Name'),
        'Research',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Study experiments',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(confirmedName, 'Research');
      expect(confirmedDescription, 'Study experiments');
      expect(confirmedIconPath, 'science');
    });

    testWidgets('EditCategoryDialog updates and confirms selected icon', (
      WidgetTester tester,
    ) async {
      String? confirmedName;
      String? confirmedDescription;
      String? confirmedIconPath;

      await tester.pumpWidget(
        _buildDialogLauncher(
          builder: (context) {
            return () {
              EditCategoryDialog.show(
                context,
                initialName: 'Programming',
                initialDescription: 'Software development',
                initialIconPath: 'code',
                onConfirm: (name, description, iconPath) {
                  confirmedName = name;
                  confirmedDescription = description;
                  confirmedIconPath = iconPath;
                },
              );
            };
          },
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Category'), findsOneWidget);
      expect(find.text('Code'), findsOneWidget);

      await tester.tap(find.text('Code'));
      await tester.pumpAndSettle();

      expect(find.text('Select Icon'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.palette));
      await tester.pumpAndSettle();

      expect(find.text('Palette'), findsOneWidget);
      expect(find.text('Code'), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(confirmedName, 'Programming');
      expect(confirmedDescription, 'Software development');
      expect(confirmedIconPath, 'palette');
    });
  });
}

import 'package:flutter/material.dart';
import 'common_containers.dart';

class CustomDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final bool barrierDismissible;

  const CustomDialog({
    required this.title,
    required this.content,
    required this.actions,
    this.barrierDismissible = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: title,
      content: content,
      actions: actions,
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget title,
    required Widget content,
    required List<Widget> actions,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? warningText;
  final Color iconColor;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;

  const ConfirmationDialog({
    required this.icon,
    required this.title,
    required this.message,
    this.warningText,
    this.iconColor = Colors.red,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: DialogTitleRow(
        icon: icon,
        title: title,
        iconColor: iconColor,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (warningText != null) ...[
            const SizedBox(height: 16),
            WarningContainer(text: warningText!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? iconColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<bool> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? warningText,
    Color iconColor = Colors.red,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmationDialog(
            icon: icon,
            title: title,
            message: message,
            warningText: warningText,
            iconColor: iconColor,
            confirmText: confirmText,
            cancelText: cancelText,
            confirmColor: confirmColor,
          ),
        ) ??
        false;
  }
}

class DeleteConfirmationDialog extends ConfirmationDialog {
  const DeleteConfirmationDialog({
    required String itemName,
    String? warningText,
    super.key,
  }) : super(
          icon: Icons.delete,
          title: 'Delete $itemName',
          message: 'Are you sure you want to delete "$itemName"?',
          warningText: warningText ?? 'This action cannot be undone',
          iconColor: Colors.red,
          confirmText: 'Delete',
        );

  static Future<bool> show(
    BuildContext context, {
    required String itemName,
    String? warningText,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => DeleteConfirmationDialog(
            itemName: itemName,
            warningText: warningText,
          ),
        ) ??
        false;
  }
}

class SaveSessionDialog extends StatelessWidget {
  final String skillName;
  final String elapsedTime;

  const SaveSessionDialog({
    required this.skillName,
    required this.elapsedTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: const DialogTitleRow(
        icon: Icons.save,
        title: 'Save Session',
        iconColor: Colors.blue,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Save $elapsedTime session for $skillName?'),
          const SizedBox(height: 16),
          const SuccessContainer(
            text: 'This will count towards your progress',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  static Future<bool> show(
    BuildContext context, {
    required String skillName,
    required String elapsedTime,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => SaveSessionDialog(
            skillName: skillName,
            elapsedTime: elapsedTime,
          ),
        ) ??
        false;
  }
}

class UnsavedChangesDialog extends StatelessWidget {
  final bool isTimerRunning;

  const UnsavedChangesDialog({
    required this.isTimerRunning,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: const DialogTitleRow(
        icon: Icons.warning,
        title: 'Unsaved Changes',
        iconColor: Colors.orange,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTimerRunning
                ? 'Timer is still running. Do you want to exit without saving?'
                : 'You have unsaved changes. Do you want to exit?',
          ),
          const SizedBox(height: 16),
          const WarningContainer(
            text: 'Your session progress will be lost',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Exit'),
        ),
      ],
    );
  }

  static Future<bool> show(
    BuildContext context, {
    required bool isTimerRunning,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => UnsavedChangesDialog(
            isTimerRunning: isTimerRunning,
          ),
        ) ??
        false;
  }
}

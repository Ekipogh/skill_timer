import 'package:flutter/material.dart';
import 'package:skill_timer/screens/icon_selector.dart';
import 'common_containers.dart';
import '../utils/icons.dart';

enum FieldTypes { text, icon }

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}

class CustomIconField extends StatelessWidget {
  final String iconPath;
  final String labelText;
  final ValueChanged<String> onChanged;

  const CustomIconField({
    required this.iconPath,
    required this.labelText,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIcon = iconMap[iconPath] ?? Icons.image;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final selectedIconPath = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => IconSelector(selectedIconPath: iconPath),
          ),
        );

        if (selectedIconPath != null) {
          onChanged(selectedIconPath);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                selectedIcon,
                color: colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatIconName(iconPath),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  String _formatIconName(String iconPath) {
    return iconPath
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class FormDialog extends StatefulWidget {
  final String title;
  final IconData titleIcon;
  final Color titleIconColor;
  final List<FormField> fields;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Widget? additionalInfo;
  final Function(Map<String, String>) onConfirm;

  const FormDialog({
    required this.title,
    required this.titleIcon,
    required this.fields,
    required this.onConfirm,
    this.titleIconColor = Colors.blue,
    this.confirmText = 'Save',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.additionalInfo,
    super.key,
  });

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {
      for (var field in widget.fields)
        field.key: TextEditingController(
          text: field.initialValue ??
              (field.type == FieldTypes.icon ? field.iconPath : null),
        ),
    };
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.titleIconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.titleIcon,
              color: widget.titleIconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(widget.title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: field.type == FieldTypes.icon
                  ? CustomIconField(
                      iconPath: controllers[field.key]!.text,
                      labelText: field.label,
                      onChanged: (selectedIconPath) {
                        setState(() {
                          controllers[field.key]!.text = selectedIconPath;
                        });
                      },
                    )
                  : CustomTextField(
                      controller: controllers[field.key]!,
                      labelText: field.label,
                      prefixIcon: field.icon,
                      maxLines: field.maxLines,
                      textCapitalization: field.textCapitalization,
                      hintText: field.hintText,
                    ),
            ),
          ),
          if (widget.additionalInfo != null) ...[
            const SizedBox(height: 8),
            widget.additionalInfo!,
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            // Check if required fields are filled
            final values = <String, String>{};
            bool isValid = true;

            for (var field in widget.fields) {
              final value = controllers[field.key]!.text.trim();
              if (field.required && value.isEmpty) {
                isValid = false;
                break;
              }
              values[field.key] = value;
            }

            if (isValid) {
              widget.onConfirm(values);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.confirmColor ?? widget.titleIconColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required IconData titleIcon,
    required List<FormField> fields,
    required Function(Map<String, String>) onConfirm,
    Color titleIconColor = Colors.blue,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Widget? additionalInfo,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FormDialog(
        title: title,
        titleIcon: titleIcon,
        fields: fields,
        onConfirm: onConfirm,
        titleIconColor: titleIconColor,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        additionalInfo: additionalInfo,
      ),
    );
  }
}

class FormField {
  final String key;
  final String label;
  final IconData? icon;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final String? hintText;
  final String? initialValue;
  final bool required;
  final FieldTypes type;
  final String iconPath; // For icon fields

  const FormField({
    required this.key,
    required this.label,
    this.icon,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.hintText,
    this.initialValue,
    this.required = true,
    this.type = FieldTypes.text,
    this.iconPath = "psychology", // Default icon path
  });
}

// Predefined form dialogs for common use cases
class AddSkillDialog extends StatelessWidget {
  final Function(String name, String description, String iconPath) onConfirm;

  const AddSkillDialog({required this.onConfirm, super.key});

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'Add Skill',
      titleIcon: Icons.add,
      titleIconColor: Colors.blue,
      fields: const [
        FormField(
          key: 'icon',
          label: 'Icon',
          icon: Icons.image,
          textCapitalization: TextCapitalization.none,
          required: true,
          type: FieldTypes.icon,
          iconPath: "psychology", // Default icon path
        ),
        FormField(
          key: 'name',
          label: 'Skill Name',
          icon: Icons.label,
          textCapitalization: TextCapitalization.words,
          required: true,
        ),
        FormField(
          key: 'description',
          label: 'Description',
          icon: Icons.description,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          required: false,
        ),
      ],
      additionalInfo: const TipContainer(
        text: 'Skills help you track specific learning goals',
      ),
      onConfirm: (values) {
        onConfirm(values['name']!, values['description']!, values['icon']!);
      },
    );
  }

  static Future<void> show(
    BuildContext context, {
    required Function(String name, String description, String iconPath) onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddSkillDialog(onConfirm: onConfirm),
    );
  }
}

class EditSkillDialog extends StatelessWidget {
  final String initialName;
  final String initialDescription;
  final String initialIconPath;
  final Function(String name, String description, String iconPath) onConfirm;

  const EditSkillDialog({
    required this.initialName,
    required this.initialDescription,
    required this.initialIconPath,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'Edit Skill',
      titleIcon: Icons.edit,
      titleIconColor: Colors.orange,
      confirmColor: Colors.orange,
      fields: [
        FormField(
          key: 'icon',
          label: 'Icon',
          icon: Icons.image,
          textCapitalization: TextCapitalization.none,
          initialValue: initialIconPath, // Default icon path
          required: true,
          type: FieldTypes.icon,
        ),
        FormField(
          key: 'name',
          label: 'Skill Name',
          icon: Icons.label,
          textCapitalization: TextCapitalization.words,
          initialValue: initialName,
          required: true,
        ),
        FormField(
          key: 'description',
          label: 'Description',
          icon: Icons.description,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          initialValue: initialDescription,
          required: false,
        ),
      ],
      onConfirm: (values) {
        onConfirm(values['name']!, values['description']!, values['icon']!);
      },
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String initialName,
    required String initialDescription,
    required String initialIconPath,
    required Function(String name, String description, String iconPath) onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditSkillDialog(
        initialName: initialName,
        initialDescription: initialDescription,
        initialIconPath: initialIconPath,
        onConfirm: onConfirm,
      ),
    );
  }
}

class AddCategoryDialog extends StatelessWidget {
  final Function(String name, String description, String iconPath) onConfirm;

  const AddCategoryDialog({required this.onConfirm, super.key});

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'Add Skill Category',
      titleIcon: Icons.add,
      titleIconColor: Colors.blue,
      fields: const [
        FormField(
          key: 'icon',
          label: 'Icon',
          icon: Icons.image,
          textCapitalization: TextCapitalization.none,
          required: true,
          type: FieldTypes.icon,
          iconPath: "psychology", // Default icon path
        ),
        FormField(
          key: 'name',
          label: 'Name',
          icon: Icons.label,
          textCapitalization: TextCapitalization.words,
          required: true,
        ),
        FormField(
          key: 'description',
          label: 'Description',
          icon: Icons.description,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          required: false,
        ),
      ],
      additionalInfo: const TipContainer(
        text: 'Categories help organize your learning goals',
      ),
      onConfirm: (values) {
        onConfirm(values['name']!, values['description']!, values['icon']!);
      },
    );
  }

  static Future<void> show(
    BuildContext context, {
    required Function(String name, String description, String iconPath)
        onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddCategoryDialog(onConfirm: onConfirm),
    );
  }
}

class EditCategoryDialog extends StatelessWidget {
  final String initialName;
  final String initialDescription;
  final String initialIconPath;
  final Function(String name, String description, String iconPath) onConfirm;

  const EditCategoryDialog({
    required this.initialName,
    required this.initialDescription,
    required this.initialIconPath,
    required this.onConfirm,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FormDialog(
      title: 'Edit Category',
      titleIcon: Icons.edit,
      titleIconColor: Colors.orange,
      confirmColor: Colors.orange,
      fields: [
        FormField(
          key: 'icon',
          label: 'Icon',
          icon: Icons.image,
          textCapitalization: TextCapitalization.none,
          initialValue: initialIconPath,
          required: true,
          type: FieldTypes.icon,
        ),
        FormField(
          key: 'name',
          label: 'Name',
          icon: Icons.label,
          textCapitalization: TextCapitalization.words,
          initialValue: initialName,
          required: true,
        ),
        FormField(
          key: 'description',
          label: 'Description',
          icon: Icons.description,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
          initialValue: initialDescription,
          required: false,
        ),
      ],
      onConfirm: (values) {
        onConfirm(values['name']!, values['description']!, values['icon']!);
      },
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String initialName,
    required String initialDescription,
    required String initialIconPath,
    required Function(String name, String description, String iconPath)
        onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditCategoryDialog(
        initialName: initialName,
        initialDescription: initialDescription,
        initialIconPath: initialIconPath,
        onConfirm: onConfirm,
      ),
    );
  }
}

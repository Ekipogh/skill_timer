import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/models/skill.dart';
import 'package:skill_timer/providers/skill_category_provider.dart';
import 'package:skill_timer/utils/formatters.dart';
import 'package:skill_timer/widgets/widgets.dart';

class ManualDataEntryScreen extends StatelessWidget {
  final Skill skill;

  const ManualDataEntryScreen({required this.skill, super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithGradient(
      appBar: CustomAppBar(title: "Manual Data Entry for ${skill.name}"),
      body: GeneralGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconCard(
                  icon: Icons.psychology,
                  title: "${skill.name} Manual Entry",
                  subtitle: skill.description.isNotEmpty
                      ? skill.description
                      : null,
                  iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  iconBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                const SizedBox(height: 16),
                DialogTitleRow(
                  icon: Icons.edit,
                  title: "Enter your data manually",
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                ManualDataEntryForm(skill: skill),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ManualDataEntryForm extends StatefulWidget {
  final Skill skill;

  const ManualDataEntryForm({required this.skill, super.key});

  @override
  State<ManualDataEntryForm> createState() => _ManualDataEntryFormState();
}

class _ManualDataEntryFormState extends State<ManualDataEntryForm> {
  final TextEditingController _controller = TextEditingController();

  int _durationTime = 0; // Duration in seconds
  DateTime? _selectedDate;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize with today's date
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration Picker
            GestureDetector(
              onTap: () async {
                final result = await showTimerPickerDialog(
                  context: context,
                  initialTime: _durationTime,
                );
                if (result != null) {
                  setState(() {
                    _durationTime = result;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Duration',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            Formatters.formatDuration(_durationTime),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker
            GestureDetector(
              onTap: () async {
                final result = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (result != null) {
                  setState(() {
                    _selectedDate = result;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            _selectedDate != null
                                ? Formatters.formatDate(_selectedDate!)
                                : 'Select date',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _durationTime > 0 && _selectedDate != null
                    ? () => _saveManualSession(context)
                    : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveManualSession(BuildContext context) async {
    final skillProvider = context.read<SkillProvider>();

    final sessionData = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      'skillId': widget.skill.id,
      'duration': _durationTime,
      'datePerformed': _selectedDate!.toIso8601String(),
    };

    try {
      await skillProvider.addSession(sessionData);
    } catch (e) {
      CustomSnackBar.showError(context, message: 'Failed to save session: $e');
      return;
    }

    CustomSnackBar.showSuccess(
      context,
      message:
          'Manual session saved: ${Formatters.formatDuration(_durationTime)} on ${Formatters.formatDate(_selectedDate!)}',
    );

    // Navigate back
    Navigator.of(context).pop();
  }

  // Show custom duration picker dialog
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
                  _selectPresetDuration(context, setState, duration);
                }),
                _buildPresetButton(context, '15 min', 15 * 60, (duration) {
                  _selectPresetDuration(context, setState, duration);
                }),
                _buildPresetButton(context, '30 min', 30 * 60, (duration) {
                  _selectPresetDuration(context, setState, duration);
                }),
                _buildPresetButton(context, '1 hour', 60 * 60, (duration) {
                  _selectPresetDuration(context, setState, duration);
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Helper method to handle preset duration selection
  void _selectPresetDuration(
    BuildContext context,
    StateSetter setState,
    int duration,
  ) {
    // Close the dialog and return the selected duration
    Navigator.of(context).pop(duration);
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill_category.dart';
import '../models/skill.dart';
import '../providers/skill_category_provider.dart';
import '../widgets/widgets.dart';
import 'package:skill_timer/screens/timer_screen.dart';

class SkillsScreen extends StatefulWidget {
  final SkillCategory category;

  const SkillsScreen({required this.category, super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ScaffoldWithGradient(
      appBar: CustomAppBar(
        title: widget.category.name,
        actions: [
          CustomIconButton(
            icon: Icons.add,
            onPressed: _addNewSkill,
            tooltip: 'Add Skill',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category info card
          Container(
            margin: const EdgeInsets.all(16),
            child: IconCard(
              icon: Icons.category,
              iconBackgroundColor: colorScheme.primaryContainer,
              iconColor: colorScheme.onPrimaryContainer,
              title: widget.category.name,
              subtitle: widget.category.description.isNotEmpty
                  ? widget.category.description
                  : null,
            ),
          ),

          // Skills list
          Expanded(
            child: Consumer<SkillProvider>(
              builder: (context, provider, child) {
                final skills = provider.getSkillsForCategory(
                  widget.category.id,
                );

                if (skills.isEmpty) {
                  return EmptyStateCard(
                    icon: Icons.psychology_outlined,
                    title: 'No skills in ${widget.category.name} yet',
                    subtitle: 'Add your first skill to start tracking your progress',
                    buttonText: 'Add First Skill',
                    onButtonPressed: _addNewSkill,
                    additionalInfo: const TipContainer(
                      text: 'Tip: Swipe left to delete or right to edit skills',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    final skill = skills[index];
                    return _buildEnhancedSkillCard(skill);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSkill,
        icon: const Icon(Icons.add),
        label: const Text('Add Skill'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEnhancedSkillCard(Skill skill) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      background: SwipeBackground(isLeft: true),
      secondaryBackground: SwipeBackground(isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmationDialog(skill);
        } else if (direction == DismissDirection.startToEnd) {
          _editSkill(skill);
          return false;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteSkill(skill);
        }
      },
      child: Stack(
        children: [
          IconCard(
            icon: Icons.psychology,
            title: skill.name,
            subtitle: skill.description.isNotEmpty ? skill.description : null,
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.green,
                size: 20,
              ),
            ),
            onTap: () => _startTimer(skill),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 56), // Extra bottom padding for badges
          ),
          DraggableIndicator(key: Key('draggable_icon_${skill.id}')),
          // Stats badges - positioned to avoid overlap
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                TimeBadge(time: _formatTime(skill.totalTimeSpent)),
                const SizedBox(width: 8),
                SessionsBadge(sessions: skill.sessionsCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewSkill() {
    // Show dialog to add new skill
    _showAddSkillDialog();
  }

  void _startTimer(Skill skill) {
    // Navigate to timer screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimerScreen(skill: skill)),
    );
  }

  void _showAddSkillDialog() {
    AddSkillDialog.show(
      context,
      onConfirm: (name, description) {
        final newSkill = Skill(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          category: widget.category.id,
        );
        context.read<SkillProvider>().addSkill(newSkill);
      },
    );
  }

  void _deleteSkill(Skill skill) {
    context.read<SkillProvider>().deleteSkill(skill.id);

    // Show confirmation snackbar
    CustomSnackBar.showUndo(
      context,
      message: '${skill.name} deleted',
      onUndo: () {
        context.read<SkillProvider>().restoreSkill(skill);
      },
    );
  }

  void _editSkill(Skill skill) {
    EditSkillDialog.show(
      context,
      initialName: skill.name,
      initialDescription: skill.description,
      onConfirm: (name, description) {
        final updatedSkill = Skill(
          id: skill.id,
          name: name,
          description: description,
          category: skill.category
        );
        context.read<SkillProvider>().updateSkill(updatedSkill);
      },
    );
  }

  String _formatTime(int seconds) {
    return TimeFormatter.format(seconds);
  }

  Future<bool> _showDeleteConfirmationDialog(Skill skill) async {
    return await DeleteConfirmationDialog.show(
      context,
      itemName: skill.name,
      warningText: 'This will also delete all timer sessions',
    );
  }
}

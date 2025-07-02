import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/widgets/dragable.dart';
import '../models/skill_category.dart';
import '../models/skill.dart';
import '../providers/skill_category_provider.dart';
import '../widgets/background.dart';

class SkillsScreen extends StatefulWidget {
  final SkillCategory category;

  const SkillsScreen({required this.category, super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewSkill,
            tooltip: 'Add Skill',
          ),
        ],
      ),
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          // Get skills for this category (you'll need to implement this)
          final skills = provider.getSkillsForCategory(widget.category.id);

          if (skills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No skills in ${widget.category.name} yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first skill',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tip: Once you have skills, swipe left to delete or right to edit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              return SkillCard(
                skill: skill,
                onTap: () => _startTimer(skill),
                onDelete: () => _deleteSkill(skill),
                onEdit: () => _editSkill(skill),
              );
            },
          );
        },
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
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Skill Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newSkill = Skill(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  category: widget.category.id,
                );

                // You'll need to implement this method in your provider
                context.read<SkillProvider>().addSkill(newSkill);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteSkill(Skill skill) {
    context.read<SkillProvider>().deleteSkill(skill.id);

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${skill.name} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            context.read<SkillProvider>().restoreSkill(skill);
          },
        ),
      ),
    );
  }

  void _editSkill(Skill skill) {
    _showEditSkillDialog(skill);
  }

  void _showEditSkillDialog(Skill skill) {
    final nameController = TextEditingController(text: skill.name);
    final descriptionController = TextEditingController(text: skill.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Skill Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final updatedSkill = Skill(
                  id: skill.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  category: skill.category,
                  totalTimeSpent: skill.totalTimeSpent,
                  sessionsCount: skill.sessionsCount,
                );

                // You'll need to implement this method in your SkillProvider
                context.read<SkillProvider>().updateSkill(updatedSkill);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const SkillCard({
    required this.skill,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(skill.id),
      direction: DismissDirection.horizontal,
      background: SwipeBackground(isLeft: true),
      secondaryBackground: SwipeBackground(isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swiping left to delete
          return await _showDeleteConfirmation(context);
        } else if (direction == DismissDirection.startToEnd) {
          // Swiping right to edit
          onEdit?.call();
          return false; // Don't dismiss, just trigger edit
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.psychology, color: Theme.of(context).primaryColor),
              ),
              title: Text(
                skill.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (skill.description.isNotEmpty) Text(skill.description),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTime(skill.totalTimeSpent)} • ${skill.sessionsCount} sessions',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: onTap,
                tooltip: 'Start Timer',
              ),
              onTap: onTap,
            ),
            DragableIcon(
              key: Key('dragable_icon_${skill.id}'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "${skill.name}"?\n\nThis will also delete all associated timer sessions.'),
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
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }
}

// Placeholder for TimerScreen
class TimerScreen extends StatelessWidget {
  final Skill skill;

  const TimerScreen({required this.skill, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Timer - ${skill.name}')),
      body: Center(
        child: Text(
          'Timer screen for ${skill.name}\n(To be implemented)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

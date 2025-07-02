import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill_category.dart';
import '../models/skill.dart';
import '../providers/skill_category_provider.dart';

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
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              return SkillCard(skill: skill, onTap: () => _startTimer(skill));
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
}

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;

  const SkillCard({required this.skill, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
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
    );
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

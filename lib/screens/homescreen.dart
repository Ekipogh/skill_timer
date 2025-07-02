import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_timer/widgets/background.dart';
import 'package:skill_timer/widgets/dragable.dart';
import '../providers/skill_category_provider.dart';
import '../models/skill_category.dart';
import 'skills_screen.dart';
import '../utils/icons.dart';

class SkillCategoryTile extends StatelessWidget {
  final SkillCategory skillCategory;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SkillCategoryTile({
    required this.skillCategory,
    required this.onTap,
    super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(skillCategory.id),
      direction: DismissDirection.horizontal,
      background: SwipeBackground(isLeft: true),
      secondaryBackground: SwipeBackground(isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmationDialog(context, skillCategory);
        } else if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false; // No action for edit, handled in onTap
        }
        return false; // No action for other directions
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Stack(
          children: [
            ListTile(
              leading: Icon(
                getIcon(iconName: skillCategory.iconPath),
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                skillCategory.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(skillCategory.description),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: onTap,
            ),
            DragableIcon(key: Key('dragable_icon_${skillCategory.id}')),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(
    BuildContext context,
    SkillCategory skillCategory,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill Category'),
        content: Text(
          'Are you sure you want to delete "${skillCategory.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SkillProvider>().deleteSkillCategory(
                skillCategory.id,
              );
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load skill categories when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkillProvider>().loadSkillCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.timer_outlined),
        title: const Text('Skill Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SkillProvider>().refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading && provider.skillCategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (provider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No skill categories yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first skill category',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Data loaded successfully
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.skillCategories.length,
              itemBuilder: (context, index) {
                final skillCategory = provider.skillCategories[index];
                return SkillCategoryTile(
                  skillCategory: skillCategory,
                  onTap: () => _onSkillCategoryTap(skillCategory),
                  onEdit: () => _editSkillCategory(skillCategory),
                  onDelete: () => _deleteSkillCategory(skillCategory),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSkillCategory,
        tooltip: 'Add Skill Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onSkillCategoryTap(SkillCategory skillCategory) {
    // Navigate to skills screen for this category
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillsScreen(category: skillCategory),
      ),
    );
  }

  void _addNewSkillCategory() {
    // Show dialog to add new skill category
    _showAddSkillCategoryDialog();
  }

  void _showAddSkillCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
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
                final newCategory = SkillCategory(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  iconPath: 'school', // Default icon
                );

                context.read<SkillProvider>().addSkillCategory(newCategory);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSkillCategoryDialog(SkillCategory skillCategory) {
    final nameController = TextEditingController(text: skillCategory.name);
    final descriptionController = TextEditingController(
      text: skillCategory.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Skill Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
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
                final updatedCategory = skillCategory.copyWith(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                context.read<SkillProvider>().updateSkillCategory(
                  updatedCategory,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editSkillCategory(SkillCategory skillCategory) {
    // Show dialog to edit existing skill category
    _showEditSkillCategoryDialog(skillCategory);
  }

  void _deleteSkillCategory(SkillCategory skillCategory) {
    // Show confirmation dialog before deleting
    context.read<SkillProvider>().deleteSkillCategory(skillCategory.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${skillCategory.name}" skill category'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<SkillProvider>().restoreSkillCategory(
              skillCategory,
            );
          },
        ),
      ),
    );
  }
}

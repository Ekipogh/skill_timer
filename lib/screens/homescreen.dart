import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/skill_category_provider.dart';
import '../models/skill_category.dart';
import '../widgets/widgets.dart';
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
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      background: SwipeBackground(isLeft: true),
      secondaryBackground: SwipeBackground(isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmationDialog(context);
        } else if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false; // No action for edit, handled in onTap
        }
        return false; // No action for other directions
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
            DraggableIndicator(key: Key('dragable_icon_${skillCategory.id}')),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await DeleteConfirmationDialog.show(
      context,
      itemName: skillCategory.name,
      warningText: 'This action cannot be undone',
    );
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
    return ScaffoldWithGradient(
      appBar: CustomAppBar(
        title: 'Skill Timer',
        actions: [
          CustomIconButton(
            icon: Icons.refresh,
            onPressed: () {
              context.read<SkillProvider>().refresh();
            },
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading && provider.skillCategories.isEmpty) {
            return const LoadingCard(text: 'Loading your skills...');
          }

          // Error state
          if (provider.hasError) {
            return ErrorCard(
              title: 'Oops! Something went wrong',
              message: provider.error ?? 'Unknown error',
              buttonText: 'Try Again',
              onButtonPressed: () => provider.refresh(),
            );
          }

          // Empty state
          if (provider.isEmpty) {
            return EmptyStateCard(
              icon: Icons.school_outlined,
              title: 'No skill categories yet',
              subtitle: 'Create your first skill category to start tracking your learning journey',
              buttonText: 'Add First Category',
              onButtonPressed: _addNewSkillCategory,
            );
          }

          // Data loaded successfully
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.skillCategories.length,
              itemBuilder: (context, index) {
                final skillCategory = provider.skillCategories[index];
                return _buildEnhancedSkillCategoryTile(skillCategory);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSkillCategory,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        tooltip: 'Add Skill Category',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEnhancedSkillCategoryTile(SkillCategory skillCategory) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      background: SwipeBackground(isLeft: true),
      secondaryBackground: SwipeBackground(isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmationDialog(skillCategory);
        } else if (direction == DismissDirection.startToEnd) {
          _editSkillCategory(skillCategory);
          return false;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteSkillCategory(skillCategory);
        }
      },
      child: Stack(
        children: [
          IconCard(
            icon: getIcon(iconName: skillCategory.iconPath),
            title: skillCategory.name,
            subtitle: skillCategory.description,
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            onTap: () => _onSkillCategoryTap(skillCategory),
          ),
          DraggableIndicator(key: Key('dragable_icon_${skillCategory.id}')),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(
    SkillCategory skillCategory,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('Delete Category'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete "${skillCategory.name}"?',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
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
    AddCategoryDialog.show(
      context,
      onConfirm: (name, description) {
        final newCategory = SkillCategory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          iconPath: 'school', // Default icon
        );
        context.read<SkillProvider>().addSkillCategory(newCategory);
      },
    );
  }

  void _showEditSkillCategoryDialog(SkillCategory skillCategory) {
    EditCategoryDialog.show(
      context,
      initialName: skillCategory.name,
      initialDescription: skillCategory.description,
      onConfirm: (name, description) {
        final updatedCategory = skillCategory.copyWith(
          name: name,
          description: description,
        );
        context.read<SkillProvider>().updateSkillCategory(updatedCategory);
      },
    );
  }

  void _editSkillCategory(SkillCategory skillCategory) {
    // Show dialog to edit existing skill category
    _showEditSkillCategoryDialog(skillCategory);
  }

  void _deleteSkillCategory(SkillCategory skillCategory) {
    // Immediately delete from provider to remove from UI
    context.read<SkillProvider>().deleteSkillCategory(skillCategory.id);

    // Show confirmation snackbar with undo option
    CustomSnackBar.showUndo(
      context,
      message: 'Deleted "${skillCategory.name}" skill category',
      onUndo: () {
        // Restore the skill category if undo is pressed
        context.read<SkillProvider>().restoreSkillCategory(skillCategory);
      },
    );
  }
}

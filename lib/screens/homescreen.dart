import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/skill_category_provider.dart';
import '../models/skill_category.dart';

class SkillTile extends StatelessWidget {
  final SkillCategory skillCategory;
  final VoidCallback onTap;

  const SkillTile({
    required this.skillCategory,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.school, // You can map iconPath to actual icons later
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
      context.read<SkillCategoryProvider>().loadSkillCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SkillCategoryProvider>().refresh();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<SkillCategoryProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading && provider.skillCategories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
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
                return SkillTile(
                  skillCategory: skillCategory,
                  onTap: () => _onSkillCategoryTap(skillCategory),
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
    // Navigate to skill timer screen for this category
    print("Tapped on skill category: ${skillCategory.name}");
    // TODO: Navigate to timer screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting timer for ${skillCategory.name}'),
        duration: const Duration(seconds: 2),
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

                context.read<SkillCategoryProvider>().addSkillCategory(newCategory);
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

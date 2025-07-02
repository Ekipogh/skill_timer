import 'package:flutter/material.dart';

class SkillTile extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const SkillTile({
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      onTap: onTap,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Timer')),
      body: ListView(
        children: [
          SkillTile(title: "Skill 1", description: "Skill 1 description", onTap: onTap),
          SkillTile(title: "Skill 2", description: "Skill 2 description", onTap: onTap),
          SkillTile(title: "Skill 3", description: "Skill 3 description", onTap: onTap),
          // Add more skills as needed
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the floating action button
        },
        tooltip: 'Action',
        child: const Icon(Icons.add),
      ),
    );
  }

  void onTap() {
    // Handle skill tile tap
    print("Skill tile tapped");
  }
}

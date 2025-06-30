class SkillCategory {
  final String name;
  final String description;
  final String iconPath;

  SkillCategory({
    required this.name,
    required this.description,
    required this.iconPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconPath': iconPath,
    };
  }

  @override
  String toString() {
    return 'SkillCategory(name: $name, description: $description, iconPath: $iconPath)';
  }
}

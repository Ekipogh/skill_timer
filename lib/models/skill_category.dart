class SkillCategory {
  final String id;
  final String name;
  final String description;
  final String iconPath;

  SkillCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconPath = "psychology",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
    };
  }

  @override
  String toString() {
    return 'SkillCategory(id: $id, name: $name, description: $description, iconPath: $iconPath)';
  }

  SkillCategory copyWith({String? name, String? description, String? iconPath}) {
    return SkillCategory(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}

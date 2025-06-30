class Skill {
  final String id;
  final String name;
  final String description;
  final String category;
  final DateTime createdAt;
  final int totalTimeSpent; // in seconds
  final int sessionsCount;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdAt,
    this.totalTimeSpent = 0,
    this.sessionsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'totalTimeSpent': totalTimeSpent,
      'sessionsCount': sessionsCount,
    };
  }

  @override
  String toString() {
    return 'Skill(id: $id, name: $name)';
  }
}

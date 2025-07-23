class Skill {
  final String id;
  final String name;
  final String description;
  final String category;
  final int totalTimeSpent; // in seconds
  final int sessionsCount;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.totalTimeSpent = 0,
    this.sessionsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category
    };
  }

  // Alias for toMap() for consistency with common Flutter patterns
  Map<String, dynamic> toJson() => toMap();

  // Create from JSON/Map
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      sessionsCount: json['sessionsCount'] ?? 0,
    );
  }

  // Copy with changes
  Skill copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? totalTimeSpent,
    int? sessionsCount,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      sessionsCount: sessionsCount ?? this.sessionsCount,
    );
  }

  @override
  String toString() {
    return 'Skill(id: $id, name: $name)';
  }

  static Skill fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      totalTimeSpent: map['totalTimeSpent'] ?? 0,
      sessionsCount: map['sessionsCount'] ?? 0,
    );
  }
}

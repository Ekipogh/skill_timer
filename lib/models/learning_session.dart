class LearningSession {
  final String id;
  final String skillId;
  final DateTime datePerformed;
  final int duration; // Duration in seconds

  LearningSession({
    required this.id,
    required this.skillId,
    required this.datePerformed,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'skillId': skillId,
      'datePerformed': datePerformed.toIso8601String(),
      'duration': duration,
    };
  }

  @override
  String toString() {
    return 'LearningSession(id: $id, skillId: $skillId, datePerformed: $datePerformed, duration: $duration)';
  }

  LearningSession copyWith({
    String? id,
    String? skillId,
    DateTime? datePerformed,
    int? duration,
  }) {
    return LearningSession(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      datePerformed: datePerformed ?? this.datePerformed,
      duration: duration ?? this.duration,
    );
  }

  static LearningSession fromMap(Map<String, Object> session) {
    return LearningSession(
      id: session['id'] as String,
      skillId: session['skillId'] as String,
      datePerformed: DateTime.parse(session['datePerformed'] as String),
      duration: session['duration'] as int,
    );
  }
}

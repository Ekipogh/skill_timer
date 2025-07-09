class TimerSession {
  final String id;
  final String skillId;
  final DateTime datePerformed;
  final int duration; // Duration in seconds

  TimerSession({
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
    return 'TimerSession(id: $id, skillId: $skillId, datePerformed: $datePerformed, duration: $duration)';
  }

  TimerSession copyWith({
    String? id,
    String? skillId,
    DateTime? datePerformed,
    int? duration,
  }) {
    return TimerSession(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      datePerformed: datePerformed ?? this.datePerformed,
      duration: duration ?? this.duration,
    );
  }
}

class TimerSession {
  final String id;
  final String skillId;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // in seconds
  final String? notes;
  final bool isCompleted;

  TimerSession({
    required this.id,
    required this.skillId,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.notes,
    this.isCompleted = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillId': skillId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  // Create from JSON
  factory TimerSession.fromJson(Map<String, dynamic> json) {
    return TimerSession(
      id: json['id'],
      skillId: json['skillId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'] ?? 0,
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  // Copy with changes
  TimerSession copyWith({
    String? id,
    String? skillId,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? notes,
    bool? isCompleted,
  }) {
    return TimerSession(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Helper method to get formatted duration
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

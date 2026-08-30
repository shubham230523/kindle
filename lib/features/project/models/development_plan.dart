import 'phase.dart';

class DevelopmentPlan {
  final String id;
  final String projectId;
  final List<Phase> phases;
  final DateTime createdAt;

  const DevelopmentPlan({
    required this.id,
    required this.projectId,
    this.phases = const [],
    required this.createdAt,
  });

  DevelopmentPlan copyWith({
    String? id,
    String? projectId,
    List<Phase>? phases,
    DateTime? createdAt,
  }) {
    return DevelopmentPlan(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      phases: phases ?? this.phases,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'phases': phases.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DevelopmentPlan.fromMap(Map<String, dynamic> map) {
    return DevelopmentPlan(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      phases: List<Phase>.from(
        (map['phases'] as List? ?? []).map((x) => Phase.fromMap(x)),
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

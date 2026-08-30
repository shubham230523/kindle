enum RequirementPriority { low, medium, high }

class Requirement {
  final String id;
  final String title;
  final String description;
  final RequirementPriority priority;

  const Requirement({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
  });

  Requirement copyWith({
    String? id,
    String? title,
    String? description,
    RequirementPriority? priority,
  }) {
    return Requirement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
    };
  }

  factory Requirement.fromMap(Map<String, dynamic> map) {
    return Requirement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: RequirementPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => RequirementPriority.medium,
      ),
    );
  }
}

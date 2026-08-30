enum RequirementPriority { low, medium, high }

enum RequirementType { functional, nonFunctional }

class Requirement {
  final String id;
  final String title;
  final String description;
  final RequirementPriority priority;
  final RequirementType type;

  const Requirement({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.type = RequirementType.functional,
  });

  Requirement copyWith({
    String? id,
    String? title,
    String? description,
    RequirementPriority? priority,
    RequirementType? type,
  }) {
    return Requirement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'type': type.name,
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
      type: RequirementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RequirementType.functional,
      ),
    );
  }
}

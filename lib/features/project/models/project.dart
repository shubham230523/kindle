import 'requirement.dart';
import 'feature.dart';
import 'screen_definition.dart';

enum ProjectStatus { draft, inProgress, completed, archived }

class Project {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final DateTime createdAt;
  final List<Requirement> requirements;
  final List<Feature> features;
  final List<ScreenDefinition> screens;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.requirements = const [],
    this.features = const [],
    this.screens = const [],
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? createdAt,
    List<Requirement>? requirements,
    List<Feature>? features,
    List<ScreenDefinition>? screens,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      requirements: requirements ?? this.requirements,
      features: features ?? this.features,
      screens: screens ?? this.screens,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'requirements': requirements.map((x) => x.toMap()).toList(),
      'features': features.map((x) => x.toMap()).toList(),
      'screens': screens.map((x) => x.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.draft,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      requirements: List<Requirement>.from(
        (map['requirements'] as List? ?? []).map((x) => Requirement.fromMap(x)),
      ),
      features: List<Feature>.from(
        (map['features'] as List? ?? []).map((x) => Feature.fromMap(x)),
      ),
      screens: List<ScreenDefinition>.from(
        (map['screens'] as List? ?? []).map((x) => ScreenDefinition.fromMap(x)),
      ),
    );
  }
}

enum ArtifactStatus { current, outdated, processing, failed }

enum ArtifactType { sourceCode, documentation, architecture, plan, build, testReport }

class ProjectArtifact {
  final String id;
  final String name;
  final ArtifactType type;
  final DateTime generatedAt;
  final ArtifactStatus status;
  final String size;

  const ProjectArtifact({
    required this.id,
    required this.name,
    required this.type,
    required this.generatedAt,
    required this.status,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'generatedAt': generatedAt.toIso8601String(),
      'status': status.name,
      'size': size,
    };
  }

  factory ProjectArtifact.fromMap(Map<String, dynamic> map) {
    return ProjectArtifact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: ArtifactType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ArtifactType.documentation,
      ),
      generatedAt: DateTime.tryParse(map['generatedAt'] ?? '') ?? DateTime.now(),
      status: ArtifactStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ArtifactStatus.current,
      ),
      size: map['size'] ?? '',
    );
  }
}

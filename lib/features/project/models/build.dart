enum BuildStatus { queued, running, successful, failed }

class BuildArtifact {
  final String name;
  final String size;
  final String type;
  final String downloadUrl;

  const BuildArtifact({
    required this.name,
    required this.size,
    required this.type,
    required this.downloadUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'size': size,
      'type': type,
      'downloadUrl': downloadUrl,
    };
  }

  factory BuildArtifact.fromMap(Map<String, dynamic> map) {
    return BuildArtifact(
      name: map['name'] ?? '',
      size: map['size'] ?? '',
      type: map['type'] ?? '',
      downloadUrl: map['downloadUrl'] ?? '',
    );
  }
}

class ProjectBuild {
  final String id;
  final String platform;
  final BuildStatus status;
  final double progress;
  final DateTime startedAt;
  final DateTime? completedAt;
  final BuildArtifact? artifact;
  final String? errorMessage;

  const ProjectBuild({
    required this.id,
    required this.platform,
    required this.status,
    this.progress = 0.0,
    required this.startedAt,
    this.completedAt,
    this.artifact,
    this.errorMessage,
  });

  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  ProjectBuild copyWith({
    BuildStatus? status,
    double? progress,
    DateTime? completedAt,
    BuildArtifact? artifact,
    String? errorMessage,
  }) {
    return ProjectBuild(
      id: id,
      platform: platform,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      artifact: artifact ?? this.artifact,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform': platform,
      'status': status.name,
      'progress': progress,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'artifact': artifact?.toMap(),
      'errorMessage': errorMessage,
    };
  }

  factory ProjectBuild.fromMap(Map<String, dynamic> map) {
    return ProjectBuild(
      id: map['id'] ?? '',
      platform: map['platform'] ?? '',
      status: BuildStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BuildStatus.queued,
      ),
      progress: (map['progress'] as num? ?? 0.0).toDouble(),
      startedAt: DateTime.tryParse(map['startedAt'] ?? '') ?? DateTime.now(),
      completedAt: DateTime.tryParse(map['completedAt'] ?? ''),
      artifact: map['artifact'] != null ? BuildArtifact.fromMap(map['artifact']) : null,
      errorMessage: map['errorMessage'],
    );
  }
}

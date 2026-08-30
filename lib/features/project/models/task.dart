enum TaskStatus { todo, inProgress, done, blocked }

enum TaskComplexity { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final String phaseId;
  final List<String> dependencies;
  final TaskComplexity complexity;
  final TaskStatus status;
  final Map<String, dynamic> metadata; // For future agent execution data

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.phaseId,
    this.dependencies = const [],
    this.complexity = TaskComplexity.medium,
    this.status = TaskStatus.todo,
    this.metadata = const {},
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? phaseId,
    List<String>? dependencies,
    TaskComplexity? complexity,
    TaskStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      phaseId: phaseId ?? this.phaseId,
      dependencies: dependencies ?? this.dependencies,
      complexity: complexity ?? this.complexity,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'phaseId': phaseId,
      'dependencies': dependencies,
      'complexity': complexity.name,
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      phaseId: map['phaseId'] ?? '',
      dependencies: List<String>.from(map['dependencies'] as List? ?? []),
      complexity: TaskComplexity.values.firstWhere(
        (e) => e.name == map['complexity'],
        orElse: () => TaskComplexity.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }
}

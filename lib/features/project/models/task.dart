enum TaskStatus { todo, inProgress, done, blocked }

enum TaskComplexity { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final String? expectedOutput;
  final List<String> filesToChange;
  final List<String> acceptanceCriteria;
  final String phaseId;
  final List<String> dependencies;
  final TaskComplexity complexity;
  final TaskStatus status;
  final Map<String, dynamic> metadata; // For future agent execution data

  const Task({
    required this.id,
    required this.title,
    required this.description,
    this.expectedOutput,
    this.filesToChange = const [],
    this.acceptanceCriteria = const [],
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
    String? expectedOutput,
    List<String>? filesToChange,
    List<String>? acceptanceCriteria,
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
      expectedOutput: expectedOutput ?? this.expectedOutput,
      filesToChange: filesToChange ?? this.filesToChange,
      acceptanceCriteria: acceptanceCriteria ?? this.acceptanceCriteria,
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
      'expectedOutput': expectedOutput,
      'filesToChange': filesToChange,
      'acceptanceCriteria': acceptanceCriteria,
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
      expectedOutput: map['expectedOutput'],
      filesToChange: List<String>.from(map['filesToChange'] as List? ?? []),
      acceptanceCriteria: List<String>.from(map['acceptanceCriteria'] as List? ?? []),
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

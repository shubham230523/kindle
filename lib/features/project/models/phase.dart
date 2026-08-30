import 'task.dart';

class Phase {
  final String id;
  final String title;
  final String description;
  final List<Task> tasks;

  const Phase({
    required this.id,
    required this.title,
    required this.description,
    this.tasks = const [],
  });

  Phase copyWith({
    String? id,
    String? title,
    String? description,
    List<Task>? tasks,
  }) {
    return Phase(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tasks': tasks.map((x) => x.toMap()).toList(),
    };
  }

  factory Phase.fromMap(Map<String, dynamic> map) {
    return Phase(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tasks: List<Task>.from(
        (map['tasks'] as List? ?? []).map((x) => Task.fromMap(x)),
      ),
    );
  }
}

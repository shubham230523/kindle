enum AgentType { architect, developer, tester, manager }

enum AgentStatus { idle, running, offline }

class Agent {
  final String id;
  final String name;
  final AgentType type;
  final String description;
  final AgentStatus status;

  const Agent({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.status = AgentStatus.idle,
  });

  Agent copyWith({
    String? id,
    String? name,
    AgentType? type,
    String? description,
    AgentStatus? status,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'status': status.name,
    };
  }

  factory Agent.fromMap(Map<String, dynamic> map) {
    return Agent(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: AgentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AgentType.developer,
      ),
      description: map['description'] ?? '',
      status: AgentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AgentStatus.idle,
      ),
    );
  }
}

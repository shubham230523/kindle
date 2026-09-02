enum ExecutionStatus { idle, waiting, planning, running, completed, failed }

class ExecutionLog {
  final DateTime timestamp;
  final String message;
  final String? level;
  final String? details;

  const ExecutionLog({
    required this.timestamp,
    required this.message,
    this.level,
    this.details,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'level': level,
      'details': details,
    };
  }

  factory ExecutionLog.fromMap(Map<String, dynamic> map) {
    return ExecutionLog(
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      message: map['message'] ?? '',
      level: map['level'],
      details: map['details'],
    );
  }
}

class AgentExecution {
  final String id;
  final String agentId;
  final String taskId;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<ExecutionLog> logs;
  final dynamic result; // Stores CodingResult or other agent outputs

  const AgentExecution({
    required this.id,
    required this.agentId,
    required this.taskId,
    this.status = ExecutionStatus.idle,
    required this.startedAt,
    this.completedAt,
    this.logs = const [],
    this.result,
  });

  AgentExecution copyWith({
    String? id,
    String? agentId,
    String? taskId,
    ExecutionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    List<ExecutionLog>? logs,
    dynamic result,
  }) {
    return AgentExecution(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      taskId: taskId ?? this.taskId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      logs: logs ?? this.logs,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agentId': agentId,
      'taskId': taskId,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'logs': logs.map((x) => x.toMap()).toList(),
      'result': result,
    };
  }

  factory AgentExecution.fromMap(Map<String, dynamic> map) {
    return AgentExecution(
      id: map['id'] ?? '',
      agentId: map['agentId'] ?? '',
      taskId: map['taskId'] ?? '',
      status: ExecutionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExecutionStatus.idle,
      ),
      startedAt: DateTime.tryParse(map['startedAt'] ?? '') ?? DateTime.now(),
      completedAt: DateTime.tryParse(map['completedAt'] ?? ''),
      logs: List<ExecutionLog>.from(
        (map['logs'] as List? ?? []).map((x) => ExecutionLog.fromMap(x)),
      ),
      result: map['result'],
    );
  }
}

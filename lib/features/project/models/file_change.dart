enum FileChangeType { created, modified, deleted }

class FileChange {
  final String id;
  final String filePath;
  final FileChangeType type;
  final String agentName;
  final String taskTitle;
  final DateTime timestamp;

  const FileChange({
    required this.id,
    required this.filePath,
    required this.type,
    required this.agentName,
    required this.taskTitle,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'type': type.name,
      'agentName': agentName,
      'taskTitle': taskTitle,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FileChange.fromMap(Map<String, dynamic> map) {
    return FileChange(
      id: map['id'] ?? '',
      filePath: map['filePath'] ?? '',
      type: FileChangeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FileChangeType.modified,
      ),
      agentName: map['agentName'] ?? '',
      taskTitle: map['taskTitle'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

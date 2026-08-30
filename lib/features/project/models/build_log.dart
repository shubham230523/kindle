enum BuildLogLevel { info, warning, error, debug }

class BuildLogEntry {
  final DateTime timestamp;
  final String message;
  final BuildLogLevel level;

  const BuildLogEntry({
    required this.timestamp,
    required this.message,
    this.level = BuildLogLevel.info,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'level': level.name,
    };
  }

  factory BuildLogEntry.fromMap(Map<String, dynamic> map) {
    return BuildLogEntry(
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      message: map['message'] ?? '',
      level: BuildLogLevel.values.firstWhere(
        (e) => e.name == map['level'],
        orElse: () => BuildLogLevel.info,
      ),
    );
  }
}

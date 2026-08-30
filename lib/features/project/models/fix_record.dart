class FixRecord {
  final String id;
  final String issue;
  final String rootCause;
  final List<String> modifiedFiles;
  final String fixSummary;
  final String buildResult;
  final String testResult;
  final DateTime timestamp;

  const FixRecord({
    required this.id,
    required this.issue,
    required this.rootCause,
    required this.modifiedFiles,
    required this.fixSummary,
    required this.buildResult,
    required this.testResult,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'issue': issue,
      'rootCause': rootCause,
      'modifiedFiles': modifiedFiles,
      'fixSummary': fixSummary,
      'buildResult': buildResult,
      'testResult': testResult,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FixRecord.fromMap(Map<String, dynamic> map) {
    return FixRecord(
      id: map['id'] ?? '',
      issue: map['issue'] ?? '',
      rootCause: map['rootCause'] ?? '',
      modifiedFiles: List<String>.from(map['modifiedFiles'] ?? []),
      fixSummary: map['fixSummary'] ?? '',
      buildResult: map['buildResult'] ?? '',
      testResult: map['testResult'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class FileModification {
  final String path;
  final String content;
  final String type; // 'create' | 'modify' | 'delete'

  const FileModification({
    required this.path,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'content': content,
      'type': type,
    };
  }

  factory FileModification.fromMap(Map<String, dynamic> map) {
    return FileModification(
      path: map['path'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'create',
    );
  }
}

class CodingResult {
  final List<FileModification> changes;
  final String explanation;
  final double confidence;
  final String? reasoning;

  const CodingResult({
    required this.changes,
    required this.explanation,
    required this.confidence,
    this.reasoning,
  });

  factory CodingResult.fromMap(Map<String, dynamic> map) {
    return CodingResult(
      changes: List<FileModification>.from(
        (map['changes'] as List? ?? []).map((x) => FileModification.fromMap(x)),
      ),
      explanation: map['explanation'] ?? '',
      confidence: (map['confidence'] as num? ?? 0.0).toDouble(),
      reasoning: map['reasoning'],
    );
  }
}

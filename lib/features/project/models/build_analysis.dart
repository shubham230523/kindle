class BuildFailureAnalysis {
  final String errorSummary;
  final String likelyCause;
  final List<String> affectedFiles;
  final String suggestedSolution;
  final double confidence; // 0.0 to 1.0

  const BuildFailureAnalysis({
    required this.errorSummary,
    required this.likelyCause,
    required this.affectedFiles,
    required this.suggestedSolution,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'errorSummary': errorSummary,
      'likelyCause': likelyCause,
      'affectedFiles': affectedFiles,
      'suggestedSolution': suggestedSolution,
      'confidence': confidence,
    };
  }

  factory BuildFailureAnalysis.fromMap(Map<String, dynamic> map) {
    return BuildFailureAnalysis(
      errorSummary: map['errorSummary'] ?? '',
      likelyCause: map['likelyCause'] ?? '',
      affectedFiles: List<String>.from(map['affectedFiles'] ?? []),
      suggestedSolution: map['suggestedSolution'] ?? '',
      confidence: (map['confidence'] as num? ?? 0.0).toDouble(),
    );
  }
}

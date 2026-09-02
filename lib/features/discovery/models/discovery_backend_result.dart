class DiscoveryBackendResult {
  final String understandingSummary;
  final String? currentQuestion;
  final List<String> discoveredRequirements;
  final List<String> missingInformation;
  final double confidence;
  final bool isDiscoveryComplete;
  final String? reasoning;

  const DiscoveryBackendResult({
    required this.understandingSummary,
    this.currentQuestion,
    required this.discoveredRequirements,
    required this.missingInformation,
    required this.confidence,
    required this.isDiscoveryComplete,
    this.reasoning,
  });

  factory DiscoveryBackendResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? json;
    return DiscoveryBackendResult(
      understandingSummary: result['understandingSummary'] ?? '',
      currentQuestion: result['currentQuestion'],
      discoveredRequirements: List<String>.from(result['discoveredRequirements'] ?? []),
      missingInformation: List<String>.from(result['missingInformation'] ?? []),
      confidence: (result['confidence'] as num? ?? 0.0).toDouble(),
      isDiscoveryComplete: result['isDiscoveryComplete'] ?? false,
      reasoning: json['reasoning'],
    );
  }
}

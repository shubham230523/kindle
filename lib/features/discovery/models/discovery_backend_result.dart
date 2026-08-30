class DiscoveryBackendResult {
  final String understandingSummary;
  final String? currentQuestion;
  final List<String> discoveredRequirements;
  final List<String> missingInformation;
  final double confidence;
  final bool isDiscoveryComplete;

  const DiscoveryBackendResult({
    required this.understandingSummary,
    this.currentQuestion,
    required this.discoveredRequirements,
    required this.missingInformation,
    required this.confidence,
    required this.isDiscoveryComplete,
  });

  factory DiscoveryBackendResult.fromJson(Map<String, dynamic> json) {
    return DiscoveryBackendResult(
      understandingSummary: json['understandingSummary'] ?? '',
      currentQuestion: json['currentQuestion'],
      discoveredRequirements: List<String>.from(json['discoveredRequirements'] ?? []),
      missingInformation: List<String>.from(json['missingInformation'] ?? []),
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      isDiscoveryComplete: json['isDiscoveryComplete'] ?? false,
    );
  }
}

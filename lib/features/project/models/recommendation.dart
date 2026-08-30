class TechRecommendation {
  final String techId;
  final double confidence; // 0.0 to 1.0
  final String reason;
  final List<String> tradeoffs;
  final List<String> alternatives;

  const TechRecommendation({
    required this.techId,
    required this.confidence,
    required this.reason,
    required this.tradeoffs,
    required this.alternatives,
  });
}

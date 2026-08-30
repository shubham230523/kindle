class ScreenDefinition {
  final String name;
  final String purpose;

  const ScreenDefinition({
    required this.name,
    required this.purpose,
  });

  ScreenDefinition copyWith({
    String? name,
    String? purpose,
  }) {
    return ScreenDefinition(
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purpose': purpose,
    };
  }

  factory ScreenDefinition.fromMap(Map<String, dynamic> map) {
    return ScreenDefinition(
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
    );
  }
}

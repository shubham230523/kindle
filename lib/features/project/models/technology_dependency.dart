class TechnologyDependency {
  final String name;
  final String purpose;

  const TechnologyDependency({
    required this.name,
    required this.purpose,
  });

  TechnologyDependency copyWith({
    String? name,
    String? purpose,
  }) {
    return TechnologyDependency(
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

  factory TechnologyDependency.fromMap(Map<String, dynamic> map) {
    return TechnologyDependency(
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
    );
  }
}

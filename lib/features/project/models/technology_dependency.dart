class TechnologyDependency {
  final String name;
  final String purpose;
  final String category;
  final String whySelected;

  const TechnologyDependency({
    required this.name,
    required this.purpose,
    required this.category,
    required this.whySelected,
  });

  TechnologyDependency copyWith({
    String? name,
    String? purpose,
    String? category,
    String? whySelected,
  }) {
    return TechnologyDependency(
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      category: category ?? this.category,
      whySelected: whySelected ?? this.whySelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purpose': purpose,
      'category': category,
      'whySelected': whySelected,
    };
  }

  factory TechnologyDependency.fromMap(Map<String, dynamic> map) {
    return TechnologyDependency(
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      category: map['category'] ?? '',
      whySelected: map['whySelected'] ?? '',
    );
  }
}

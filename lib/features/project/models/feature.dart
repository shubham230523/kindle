class Feature {
  final String id;
  final String name;
  final String description;
  final String category;

  const Feature({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  Feature copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
  }) {
    return Feature(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }

  factory Feature.fromMap(Map<String, dynamic> map) {
    return Feature(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
    );
  }
}

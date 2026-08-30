class Module {
  final String name;
  final String responsibility;
  final List<String> dependencies;

  const Module({
    required this.name,
    required this.responsibility,
    this.dependencies = const [],
  });

  Module copyWith({
    String? name,
    String? responsibility,
    List<String>? dependencies,
  }) {
    return Module(
      name: name ?? this.name,
      responsibility: responsibility ?? this.responsibility,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'responsibility': responsibility,
      'dependencies': dependencies,
    };
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      name: map['name'] ?? '',
      responsibility: map['responsibility'] ?? '',
      dependencies: List<String>.from(map['dependencies'] as List? ?? []),
    );
  }
}

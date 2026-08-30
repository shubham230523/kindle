import 'module.dart';
import 'technology_dependency.dart';

enum ArchitecturePattern { mvvm, clean, mvi, layered }

class Architecture {
  final ArchitecturePattern pattern;
  final List<Module> modules;
  final List<String> layers;
  final List<TechnologyDependency> technologyDependencies;

  const Architecture({
    required this.pattern,
    this.modules = const [],
    this.layers = const [],
    this.technologyDependencies = const [],
  });

  Architecture copyWith({
    ArchitecturePattern? pattern,
    List<Module>? modules,
    List<String>? layers,
    List<TechnologyDependency>? technologyDependencies,
  }) {
    return Architecture(
      pattern: pattern ?? this.pattern,
      modules: modules ?? this.modules,
      layers: layers ?? this.layers,
      technologyDependencies: technologyDependencies ?? this.technologyDependencies,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pattern': pattern.name,
      'modules': modules.map((x) => x.toMap()).toList(),
      'layers': layers,
      'technologyDependencies': technologyDependencies.map((x) => x.toMap()).toList(),
    };
  }

  factory Architecture.fromMap(Map<String, dynamic> map) {
    return Architecture(
      pattern: ArchitecturePattern.values.firstWhere(
        (e) => e.name == map['pattern'],
        orElse: () => ArchitecturePattern.mvvm,
      ),
      modules: List<Module>.from(
        (map['modules'] as List? ?? []).map((x) => Module.fromMap(x)),
      ),
      layers: List<String>.from(map['layers'] as List? ?? []),
      technologyDependencies: List<TechnologyDependency>.from(
        (map['technologyDependencies'] as List? ?? []).map((x) => TechnologyDependency.fromMap(x)),
      ),
    );
  }
}

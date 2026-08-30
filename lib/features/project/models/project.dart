import 'requirement.dart';
import 'feature.dart';
import 'user_story.dart';
import 'screen_definition.dart';
import 'architecture.dart';
import 'development_plan.dart';
import 'file_change.dart';
import 'build.dart';
import 'test_run.dart';

enum ProjectStatus { draft, inProgress, completed, archived }

class Project {
  final String id;
  final String name;
  final String description;
  final String? targetUsers;
  final String? problemStatement;
  final ProjectStatus status;
  final DateTime createdAt;
  final List<Requirement> requirements;
  final List<Feature> features;
  final List<UserStory> userStories;
  final List<ScreenDefinition> screens;
  final List<String> platforms;
  final String? selectedTechnology;
  final String? selectedBackend;
  final String? selectedDatabase;
  final Architecture? architecture;
  final DevelopmentPlan? developmentPlan;
  final List<FileChange> fileChanges;
  final List<ProjectBuild> builds;
  final List<TestRun> testRuns;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    this.targetUsers,
    this.problemStatement,
    required this.status,
    required this.createdAt,
    this.requirements = const [],
    this.features = const [],
    this.userStories = const [],
    this.screens = const [],
    this.platforms = const [],
    this.selectedTechnology,
    this.selectedBackend,
    this.selectedDatabase,
    this.architecture,
    this.developmentPlan,
    this.fileChanges = const [],
    this.builds = const [],
    this.testRuns = const [],
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? targetUsers,
    String? problemStatement,
    ProjectStatus? status,
    DateTime? createdAt,
    List<Requirement>? requirements,
    List<Feature>? features,
    List<UserStory>? userStories,
    List<ScreenDefinition>? screens,
    List<String>? platforms,
    String? selectedTechnology,
    String? selectedBackend,
    String? selectedDatabase,
    Architecture? architecture,
    DevelopmentPlan? developmentPlan,
    List<FileChange>? fileChanges,
    List<ProjectBuild>? builds,
    List<TestRun>? testRuns,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetUsers: targetUsers ?? this.targetUsers,
      problemStatement: problemStatement ?? this.problemStatement,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      requirements: requirements ?? this.requirements,
      features: features ?? this.features,
      userStories: userStories ?? this.userStories,
      screens: screens ?? this.screens,
      platforms: platforms ?? this.platforms,
      selectedTechnology: selectedTechnology ?? this.selectedTechnology,
      selectedBackend: selectedBackend ?? this.selectedBackend,
      selectedDatabase: selectedDatabase ?? this.selectedDatabase,
      architecture: architecture ?? this.architecture,
      developmentPlan: developmentPlan ?? this.developmentPlan,
      fileChanges: fileChanges ?? this.fileChanges,
      builds: builds ?? this.builds,
      testRuns: testRuns ?? this.testRuns,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetUsers': targetUsers,
      'problemStatement': problemStatement,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'requirements': requirements.map((x) => x.toMap()).toList(),
      'features': features.map((x) => x.toMap()).toList(),
      'userStories': userStories.map((x) => x.toMap()).toList(),
      'screens': screens.map((x) => x.toMap()).toList(),
      'platforms': platforms,
      'selectedTechnology': selectedTechnology,
      'selectedBackend': selectedBackend,
      'selectedDatabase': selectedDatabase,
      'architecture': architecture?.toMap(),
      'developmentPlan': developmentPlan?.toMap(),
      'fileChanges': fileChanges.map((x) => x.toMap()).toList(),
      'builds': builds.map((x) => x.toMap()).toList(),
      'testRuns': testRuns.map((x) => x.toMap()).toList(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      targetUsers: map['targetUsers'],
      problemStatement: map['problemStatement'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.draft,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      requirements: List<Requirement>.from(
        (map['requirements'] as List? ?? []).map((x) => Requirement.fromMap(x)),
      ),
      features: List<Feature>.from(
        (map['features'] as List? ?? []).map((x) => Feature.fromMap(x)),
      ),
      userStories: List<UserStory>.from(
        (map['userStories'] as List? ?? []).map((x) => UserStory.fromMap(x)),
      ),
      screens: List<ScreenDefinition>.from(
        (map['screens'] as List? ?? []).map((x) => ScreenDefinition.fromMap(x)),
      ),
      platforms: List<String>.from(map['platforms'] as List? ?? []),
      selectedTechnology: map['selectedTechnology'],
      selectedBackend: map['selectedBackend'],
      selectedDatabase: map['selectedDatabase'],
      architecture: map['architecture'] != null ? Architecture.fromMap(map['architecture']) : null,
      developmentPlan: map['developmentPlan'] != null ? DevelopmentPlan.fromMap(map['developmentPlan']) : null,
      fileChanges: List<FileChange>.from(
        (map['fileChanges'] as List? ?? []).map((x) => FileChange.fromMap(x)),
      ),
      builds: List<ProjectBuild>.from(
        (map['builds'] as List? ?? []).map((x) => ProjectBuild.fromMap(x)),
      ),
      testRuns: List<TestRun>.from(
        (map['testRuns'] as List? ?? []).map((x) => TestRun.fromMap(x)),
      ),
    );
  }
}

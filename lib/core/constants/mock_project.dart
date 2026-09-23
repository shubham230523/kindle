import '../../features/project/models/project.dart';
import '../../features/project/models/requirement.dart';
import '../../features/project/models/feature.dart';
import '../../features/project/models/user_story.dart';
import '../../features/project/models/screen_definition.dart';
import '../../features/project/models/architecture.dart';
import '../../features/project/models/module.dart';
import '../../features/project/models/technology_dependency.dart';
import '../../features/project/models/development_plan.dart';
import '../../features/project/models/phase.dart';
import '../../features/project/models/task.dart';

class MockProject {
  static Project get syncTasks {
    const projectId = 'proj_synctasks_001';

    final dummyPlan = DevelopmentPlan(
      id: 'dp1',
      projectId: projectId,
      createdAt: DateTime.now(),
      phases: [
        Phase(
          id: 'p1',
          title: 'Foundations',
          description: 'Setup project structure and core configurations.',
          tasks: [
            Task(
              id: 't1',
              phaseId: 'p1',
              title: 'Initialize Project',
              description: 'Create the base project structure and repository.',
              status: TaskStatus.todo,
            ),
            Task(
              id: 't2',
              phaseId: 'p1',
              title: 'Setup Authentication',
              description: 'Implement user login and registration.',
              status: TaskStatus.todo,
            ),
          ],
        ),
        Phase(
          id: 'p2',
          title: 'Core Features',
          description: 'Implement the essential functionality of SyncTasks.',
          tasks: [
            Task(
              id: 't3',
              phaseId: 'p2',
              title: 'Task CRUD',
              description: 'Implement Create, Read, Update, and Delete for tasks.',
              status: TaskStatus.todo,
            ),
            Task(
              id: 't4',
              phaseId: 'p2',
              title: 'Cloud Sync Engine',
              description: 'Implement real-time data synchronization logic.',
              status: TaskStatus.todo,
            ),
          ],
        ),
      ],
    );

    const defaultArchitecture = Architecture(
      pattern: ArchitecturePattern.mvvm,
      layers: ['Presentation', 'Domain', 'Data'],
      modules: [
        Module(name: 'Core', responsibility: 'Shared logic and utilities'),
        Module(name: 'Features', responsibility: 'App functional modules'),
      ],
      technologyDependencies: [
        TechnologyDependency(name: 'flutter_bloc', purpose: 'State Management', category: 'State', whySelected: 'Robust BLoC pattern support'),
        TechnologyDependency(name: 'provider', purpose: 'Dependency Injection', category: 'DI', whySelected: 'Simple DI framework'),
        TechnologyDependency(name: 'dio', purpose: 'HTTP Client', category: 'Networking', whySelected: 'Supports stream transformations'),
      ],
    );

    return Project(
      id: projectId,
      name: 'SyncTasks',
      description:
          'A robust To-Do application for cross-device productivity. SyncTasks allows users to manage their daily schedules with real-time cloud synchronization between mobile and desktop.',
      targetUsers: 'Productive professionals and students',
      problemStatement: 'Difficulty keeping task lists updated across multiple devices.',
      status: ProjectStatus.draft,
      createdAt: DateTime.now(),
      selectedTechnology: 'flutter',
      selectedBackend: 'firebase',
      selectedDatabase: 'firestore',
      platforms: const ['android', 'ios'],
      requirements: const [
        Requirement(
          id: 'req_1',
          title: 'Real-time Cloud Sync',
          description: 'Tasks synced automatically across devices.',
          priority: RequirementPriority.high,
        ),
        Requirement(
          id: 'req_2',
          title: 'Offline Task Creation',
          description: 'Create tasks offline and sync when online.',
          priority: RequirementPriority.high,
        ),
        Requirement(
          id: 'req_3',
          title: 'Push Notifications',
          description: 'Timely deadline reminders.',
          priority: RequirementPriority.medium,
        ),
        Requirement(
          id: 'req_4',
          title: 'Category Tagging',
          description: 'Organize tasks with categories and priority tags.',
          priority: RequirementPriority.medium,
        ),
      ],
      features: const [
        Feature(id: 'f1', name: 'Task Management', description: 'Create, edit, and delete tasks', category: 'Core'),
        Feature(id: 'f2', name: 'Real-time Sync', description: 'Synchronize tasks with cloud DB', category: 'Sync'),
        Feature(id: 'f3', name: 'Offline Mode', description: 'Local persistence when offline', category: 'Storage'),
      ],
      userStories: const [
        UserStory(id: 'us1', actor: 'user', action: 'create tasks offline', benefit: 'I never lose my thoughts'),
        UserStory(id: 'us2', actor: 'user', action: 'sync tasks to my laptop', benefit: 'I can continue working seamlessly'),
      ],
      screens: const [
        ScreenDefinition(name: 'DashboardScreen', purpose: 'Main task list overview'),
        ScreenDefinition(name: 'TaskDetailScreen', purpose: 'Detailed view of a task'),
      ],
      developmentPlan: dummyPlan,
      architecture: defaultArchitecture,
      fileChanges: const [],
      builds: const [],
      testRuns: const [],
      fixHistory: const [],
      artifacts: const [],
    );
  }
}

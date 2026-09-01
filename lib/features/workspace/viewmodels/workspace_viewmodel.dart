import 'package:flutter/foundation.dart';
import '../../project/models/project.dart';
import '../../project/models/agent.dart';
import '../../project/models/agent_execution.dart';
import '../../project/models/task.dart';
import '../../../core/services/agent_simulator_service.dart';

import '../../project/models/phase.dart';
import '../../project/models/development_plan.dart';

import '../models/file_node.dart';

class WorkspaceViewModel extends ChangeNotifier {
  final AgentExecutionService _executionService;
  
  Project _project;
  Project get project => _project;
  
  bool _isDeveloping = false;
  bool get isDeveloping => _isDeveloping;
  
  AgentExecution? _activeExecution;
  AgentExecution? get activeExecution => _activeExecution;

  List<FileNode> _virtualFileSystem = [];
  List<FileNode> get virtualFileSystem => _virtualFileSystem;
  
  final List<Agent> _agents = [
    const Agent(id: 'a1', name: 'Discovery Agent', type: AgentType.manager, description: 'Understands ideas.'),
    const Agent(id: 'a2', name: 'Product Agent', type: AgentType.manager, description: 'Formalizes requirements.'),
    const Agent(id: 'a3', name: 'Architecture Agent', type: AgentType.architect, description: 'Blueprints system.'),
    const Agent(id: 'a4', name: 'Coding Agent', type: AgentType.developer, description: 'Writes code.'),
    const Agent(id: 'a5', name: 'Testing Agent', type: AgentType.tester, description: 'Ensures quality.'),
  ];
  
  List<Agent> get agents => _agents;
  
  WorkspaceViewModel(this._project, this._executionService) {
    _initializeFileSystem();
  }

  void _initializeFileSystem() {
    // Initial basic structure
    _virtualFileSystem = [
      FileNode(
        name: 'lib',
        isFolder: true,
        isExpanded: true,
        children: [
          FileNode(name: 'main.dart', content: 'void main() {\n  runApp(const KindleApp());\n}'),
        ],
      ),
      FileNode(name: 'pubspec.yaml', content: 'name: ${_project.name.toLowerCase().replaceAll(' ', '_')}\ndependencies:\n  flutter:\n    sdk: flutter'),
      FileNode(name: 'README.md', content: '# ${_project.name}\n\n${_project.description}'),
    ];
  }

  void startDevelopment() async {
    debugPrint('WorkspaceViewModel: startDevelopment called');
    if (_isDeveloping) {
      debugPrint('WorkspaceViewModel: Already developing, ignoring');
      return;
    }
    
    if (_project.developmentPlan == null || _project.developmentPlan!.phases.isEmpty) {
      debugPrint('WorkspaceViewModel: Development plan is empty, generating default');
      _generateDefaultPlan();
    } else {
      debugPrint('WorkspaceViewModel: Using existing plan with ${_project.developmentPlan!.phases.length} phases');
    }

    _isDeveloping = true;
    _project = _project.copyWith(status: ProjectStatus.inProgress);
    debugPrint('WorkspaceViewModel: Notifying listeners (Development Started)');
    notifyListeners();

    try {
      while (_isDeveloping) {
        debugPrint('WorkspaceViewModel: Looking for next task...');
        final nextTask = _getNextPendingTask();
        
        if (nextTask == null) {
          debugPrint('WorkspaceViewModel: No more pending tasks. Development complete.');
          _isDeveloping = false;
          _project = _project.copyWith(status: ProjectStatus.completed);
          break;
        }

        debugPrint('WorkspaceViewModel: Next task identified: ${nextTask.title} (${nextTask.id})');
        final agent = _assignAgentForTask(nextTask);
        debugPrint('WorkspaceViewModel: Assigned agent ${agent.name} (${agent.type})');
        
        debugPrint('WorkspaceViewModel: Starting stream for task ${nextTask.id}...');
        await for (final execution in _executionService.executeTask(nextTask, agent)) {
          if (!_isDeveloping) {
            debugPrint('WorkspaceViewModel: Development stopped by user mid-task');
            break;
          }
          debugPrint('WorkspaceViewModel: Execution Update: ${execution.status}');
          _activeExecution = execution;
          notifyListeners();
        }

        debugPrint('WorkspaceViewModel: Stream finished for task ${nextTask.id}');
        if (_activeExecution?.status == ExecutionStatus.completed) {
          debugPrint('WorkspaceViewModel: Marking task ${nextTask.id} as DONE');
          _markTaskAsDone(nextTask.id);
          debugPrint('WorkspaceViewModel: Simulating file generation for task ${nextTask.id}');
          _simulateFileGeneration(nextTask);
        } else {
          debugPrint('WorkspaceViewModel: Task ${nextTask.id} did not reach completed status. Stopping loop.');
          _isDeveloping = false; 
        }
      }
    } catch (e, stackTrace) {
      debugPrint('WorkspaceViewModel: CRITICAL ERROR during development loop: $e');
      debugPrint('WorkspaceViewModel: StackTrace: $stackTrace');
      _isDeveloping = false;
    } finally {
      debugPrint('WorkspaceViewModel: Development loop exited. Cleaning up...');
      _isDeveloping = false;
      _activeExecution = null;
      notifyListeners();
    }
  }

  void _simulateFileGeneration(Task task) {
    // Based on the task, add files to the virtual file system
    if (task.id == 't1' || task.title.contains('Initialize')) {
      // Already handled by _initializeFileSystem
    } else if (task.id == 't2' || task.title.contains('Authentication')) {
      _addFileToFeature('auth', 'login_screen.dart', 'class LoginScreen extends StatelessWidget {...}');
      _addFileToFeature('auth', 'auth_viewmodel.dart', 'class AuthViewModel extends ChangeNotifier {...}');
    } else if (task.id == 't3' || task.title.contains('CRUD')) {
      _addFileToFeature('tasks', 'task_list_screen.dart', 'class TaskListScreen extends StatelessWidget {...}');
      _addFileToFeature('tasks', 'task_model.dart', 'class TaskModel {...}');
    } else if (task.id == 't4' || task.title.contains('Sync')) {
      _addFileToCore('sync_engine.dart', 'class SyncEngine {...}');
    }
    notifyListeners();
  }

  void _addFileToFeature(String featureName, String fileName, String content) {
    // Logic to find 'features' folder and add file
    final lib = _virtualFileSystem.firstWhere((n) => n.name == 'lib');
    var features = lib.children?.firstWhere((n) => n.name == 'features', orElse: () {
      final f = FileNode(name: 'features', isFolder: true, children: []);
      lib.children?.add(f);
      return f;
    });
    
    var feature = features?.children?.firstWhere((n) => n.name == featureName, orElse: () {
      final f = FileNode(name: featureName, isFolder: true, children: []);
      features.children?.add(f);
      return f;
    });

    if (feature?.children?.any((n) => n.name == fileName) ?? false) return;
    feature?.children?.add(FileNode(name: fileName, content: content));
  }

  void _addFileToCore(String fileName, String content) {
    final lib = _virtualFileSystem.firstWhere((n) => n.name == 'lib');
    var core = lib.children?.firstWhere((n) => n.name == 'core', orElse: () {
      final f = FileNode(name: 'core', isFolder: true, children: []);
      lib.children?.add(f);
      return f;
    });

    if (core?.children?.any((n) => n.name == fileName) ?? false) return;
    core?.children?.add(FileNode(name: fileName, content: content));
  }

  void _generateDefaultPlan() {
    final projectId = _project.id;
    final dummyPlan = DevelopmentPlan(
      id: 'dp_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      createdAt: DateTime.now(),
      phases: [
        Phase(
          id: 'p1',
          title: 'Project Setup',
          description: 'Initial structure and configuration.',
          tasks: [
            Task(
              id: 't1',
              phaseId: 'p1',
              title: 'Bootstrap Flutter App',
              description: 'Create Flutter project and add dependencies.',
              status: TaskStatus.todo,
            ),
          ],
        ),
        Phase(
          id: 'p2',
          title: 'Core Features',
          description: 'Implementing main functionality.',
          tasks: [
            Task(
              id: 't2',
              phaseId: 'p2',
              title: 'UI Components',
              description: 'Build basic UI elements.',
              status: TaskStatus.todo,
            ),
          ],
        ),
      ],
    );
    _project = _project.copyWith(developmentPlan: dummyPlan);
    notifyListeners();
  }

  void stopDevelopment() {
    _isDeveloping = false;
    notifyListeners();
  }

  Task? _getNextPendingTask() {
    final plan = _project.developmentPlan;
    if (plan == null) return null;
    
    for (final phase in plan.phases) {
      for (final task in phase.tasks) {
        if (task.status == TaskStatus.todo || task.status == TaskStatus.blocked) {
          return task;
        }
      }
    }
    return null;
  }

  Agent _assignAgentForTask(Task task) {
    // Basic assignment logic based on phase or task title
    if (task.phaseId == 'p1' || task.phaseId == 'p2') {
      return _agents.firstWhere((a) => a.type == AgentType.architect, orElse: () => _agents[2]); // Architecture
    }
    if (task.phaseId == 'p4') {
      return _agents.firstWhere((a) => a.type == AgentType.developer, orElse: () => _agents[3]); // Coding
    }
    if (task.phaseId == 'p5') {
      return _agents.firstWhere((a) => a.type == AgentType.tester, orElse: () => _agents[4]); // Testing
    }
    return _agents[3]; // Default to Coding Agent
  }

  void _markTaskAsDone(String taskId) {
    debugPrint('WorkspaceViewModel: _markTaskAsDone called for task $taskId');
    final plan = _project.developmentPlan;
    if (plan == null) {
      debugPrint('WorkspaceViewModel: Error - plan is null in _markTaskAsDone');
      return;
    }

    final updatedPhases = plan.phases.map((phase) {
      final updatedTasks = phase.tasks.map((task) {
        if (task.id == taskId) {
          debugPrint('WorkspaceViewModel: Setting task $taskId status to DONE');
          return task.copyWith(status: TaskStatus.done);
        }
        return task;
      }).toList();
      return phase.copyWith(tasks: updatedTasks);
    }).toList();

    final updatedPlan = plan.copyWith(phases: updatedPhases);
    _project = _project.copyWith(developmentPlan: updatedPlan);
    debugPrint('WorkspaceViewModel: Project updated. Notifying listeners.');
    notifyListeners();
  }
}

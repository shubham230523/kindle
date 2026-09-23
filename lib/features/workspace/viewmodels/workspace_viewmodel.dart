import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../project/models/project.dart';
import '../../project/models/agent.dart';
import '../../project/models/agent_execution.dart';
import '../../project/models/task.dart';
import '../../../core/services/agent_simulator_service.dart';
import '../../../core/services/model_downloader_service.dart';

import '../../project/models/phase.dart';
import '../../project/models/development_plan.dart';
import '../../project/models/architecture.dart';
import '../../project/models/module.dart';

import '../models/file_node.dart';
import '../../project/models/file_change.dart';
import '../../project/models/coding_result.dart';
import '../../project/models/build.dart';
import '../../project/models/test_run.dart';
import '../../project/models/artifact.dart';
import '../../../core/utils/dev_logger.dart';

class WorkspaceViewModel extends ChangeNotifier {
  final AgentExecutionService _executionService;
  final ModelDownloaderService _downloaderService = ModelDownloaderService();
  
  Project _project;
  Project get project => _project;
  
  bool _isDeveloping = false;
  bool get isDeveloping => _isDeveloping;

  bool _isLocalAiMode = false;
  bool get isLocalAiMode => _isLocalAiMode;

  bool _isModelReady = false;
  bool get isModelReady => _isModelReady;

  Stream<DownloadProgress>? _downloadStream;
  Stream<DownloadProgress>? get downloadStream => _downloadStream;
  
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
    _loadSettings();
    _checkModelStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true for Local AI Mode, but force false on Web
    if (kIsWeb) {
      _isLocalAiMode = false;
    } else {
      _isLocalAiMode = prefs.getBool('pref_local_ai_mode') ?? true;
    }
    notifyListeners();
  }

  void toggleLocalAiMode() async {
    if (kIsWeb) return; // Prevent toggling on Web
    
    _isLocalAiMode = !_isLocalAiMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_local_ai_mode', _isLocalAiMode);
    notifyListeners();
  }

  Future<void> _checkModelStatus() async {
    _isModelReady = await _downloaderService.isModelDownloaded();
    notifyListeners();
  }

  void downloadModel() {
    _downloadStream = _downloaderService.downloadModel();
    notifyListeners();
  }

  void onDownloadDismissed() async {
    _downloadStream = null;
    await _checkModelStatus();
    notifyListeners();
    
    if (_isModelReady) {
      debugPrint('WorkspaceViewModel: Model ready after download. Resuming development.');
      startDevelopment();
    }
  }

  void _initializeFileSystem() {
    _virtualFileSystem = [
      FileNode(
        name: 'lib',
        isFolder: true,
        isExpanded: true,
        children: [
          FileNode(
            name: 'main.dart',
            content: "import 'package:flutter/material.dart';\nimport 'core/theme/app_theme.dart';\nimport 'features/auth/screens/login_screen.dart';\n\nvoid main() {\n  runApp(const SyncTasksApp());\n}\n\nclass SyncTasksApp extends StatelessWidget {\n  const SyncTasksApp({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return MaterialApp(\n      title: 'SyncTasks',\n      theme: AppTheme.lightTheme,\n      debugShowCheckedModeBanner: false,\n      home: const LoginScreen(),\n    );\n  }\n}",
          ),
          FileNode(
            name: 'core',
            isFolder: true,
            isExpanded: true,
            children: [
              FileNode(
                name: 'theme',
                isFolder: true,
                isExpanded: true,
                children: [
                  FileNode(
                    name: 'app_colors.dart',
                    content: "import 'package:flutter/material.dart';\n\nclass AppColors {\n  static const Color primary = Color(0xFF2563EB);\n  static const Color secondary = Color(0xFF3B82F6);\n  static const Color background = Color(0xFFF8FAFC);\n  static const Color surface = Colors.white;\n  static const Color textPrimary = Color(0xFF0F172A);\n  static const Color textSecondary = Color(0xFF64748B);\n}",
                  ),
                  FileNode(
                    name: 'app_theme.dart',
                    content: "import 'package:flutter/material.dart';\nimport 'app_colors.dart';\n\nclass AppTheme {\n  static ThemeData get lightTheme {\n    return ThemeData(\n      useMaterial3: true,\n      primaryColor: AppColors.primary,\n      scaffoldBackgroundColor: AppColors.background,\n      colorScheme: ColorScheme.fromSeed(\n        seedColor: AppColors.primary,\n        surface: AppColors.surface,\n      ),\n    );\n  }\n}",
                  ),
                ],
              ),
              FileNode(
                name: 'services',
                isFolder: true,
                isExpanded: true,
                children: [
                  FileNode(
                    name: 'sync_engine.dart',
                    content: "import 'dart:async';\nimport '../../features/tasks/models/task_model.dart';\n\nclass SyncEngine {\n  bool _isSyncing = false;\n  bool get isSyncing => _isSyncing;\n\n  Future<void> syncTasks(List<TaskModel> localTasks) async {\n    _isSyncing = true;\n    await Future.delayed(const Duration(seconds: 1));\n    _isSyncing = false;\n  }\n}",
                  ),
                ],
              ),
            ],
          ),
          FileNode(
            name: 'features',
            isFolder: true,
            isExpanded: true,
            children: [
              FileNode(
                name: 'auth',
                isFolder: true,
                isExpanded: true,
                children: [
                  FileNode(
                    name: 'screens',
                    isFolder: true,
                    isExpanded: true,
                    children: [
                      FileNode(
                        name: 'login_screen.dart',
                        content: "import 'package:flutter/material.dart';\nimport '../../tasks/screens/task_list_screen.dart';\n\nclass LoginScreen extends StatefulWidget {\n  const LoginScreen({super.key});\n\n  @override\n  State<LoginScreen> createState() => _LoginScreenState();\n}\n\nclass _LoginScreenState extends State<LoginScreen> {\n  final _emailController = TextEditingController();\n  final _passwordController = TextEditingController();\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(title: const Text('SyncTasks Login')),\n      body: Padding(\n        padding: const EdgeInsets.all(24.0),\n        child: Column(\n          mainAxisAlignment: MainAxisAlignment.center,\n          children: [\n            TextField(\n              controller: _emailController,\n              decoration: const InputDecoration(labelText: 'Email'),\n            ),\n            const SizedBox(height: 16),\n            TextField(\n              controller: _passwordController,\n              obscureText: true,\n              decoration: const InputDecoration(labelText: 'Password'),\n            ),\n            const SizedBox(height: 24),\n            ElevatedButton(\n              onPressed: () {\n                Navigator.pushReplacement(\n                  context,\n                  MaterialPageRoute(builder: (_) => const TaskListScreen()),\n                );\n              },\n              child: const Text('Sign In'),\n            ),\n          ],\n        ),\n      ),\n    );\n  }\n}",
                      ),
                    ],
                  ),
                ],
              ),
              FileNode(
                name: 'tasks',
                isFolder: true,
                isExpanded: true,
                children: [
                  FileNode(
                    name: 'models',
                    isFolder: true,
                    isExpanded: true,
                    children: [
                      FileNode(
                        name: 'task_model.dart',
                        content: "enum TaskPriority { low, medium, high }\n\nclass TaskModel {\n  final String id;\n  final String title;\n  final String description;\n  final bool isCompleted;\n  final TaskPriority priority;\n  final DateTime createdAt;\n\n  const TaskModel({\n    required this.id,\n    required this.title,\n    required this.description,\n    this.isCompleted = false,\n    this.priority = TaskPriority.medium,\n    required this.createdAt,\n  });\n}",
                      ),
                    ],
                  ),
                  FileNode(
                    name: 'screens',
                    isFolder: true,
                    isExpanded: true,
                    children: [
                      FileNode(
                        name: 'task_list_screen.dart',
                        content: "import 'package:flutter/material.dart';\nimport '../models/task_model.dart';\nimport 'task_detail_screen.dart';\n\nclass TaskListScreen extends StatefulWidget {\n  const TaskListScreen({super.key});\n\n  @override\n  State<TaskListScreen> createState() => _TaskListScreenState();\n}\n\nclass _TaskListScreenState extends State<TaskListScreen> {\n  final List<TaskModel> _tasks = [\n    TaskModel(\n      id: '1',\n      title: 'Initialize SyncTasks App',\n      description: 'Setup base MVVM architecture and theme tokens.',\n      isCompleted: true,\n      createdAt: DateTime.now(),\n    ),\n    TaskModel(\n      id: '2',\n      title: 'Setup Authentication',\n      description: 'Implement multi-device session login.',\n      isCompleted: false,\n      createdAt: DateTime.now(),\n    ),\n    TaskModel(\n      id: '3',\n      title: 'Cloud Sync Logic',\n      description: 'Connect local SQLite DB with Firestore sync.',\n      isCompleted: false,\n      createdAt: DateTime.now(),\n    ),\n  ];\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(title: const Text('SyncTasks Dashboard')),\n      body: ListView.builder(\n        itemCount: _tasks.length,\n        itemBuilder: (context, index) {\n          final task = _tasks[index];\n          return ListTile(\n            leading: Checkbox(\n              value: task.isCompleted,\n              onChanged: (val) {\n                setState(() {\n                  _tasks[index] = TaskModel(\n                    id: task.id,\n                    title: task.title,\n                    description: task.description,\n                    isCompleted: val ?? false,\n                    priority: task.priority,\n                    createdAt: task.createdAt,\n                  );\n                });\n              },\n            ),\n            title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),\n            subtitle: Text(task.description),\n            onTap: () {\n              Navigator.push(\n                context,\n                MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),\n              );\n            },\n          );\n        },\n      ),\n      floatingActionButton: FloatingActionButton(\n        onPressed: () {},\n        child: const Icon(Icons.add),\n      ),\n    );\n  }\n}",
                      ),
                      FileNode(
                        name: 'task_detail_screen.dart',
                        content: "import 'package:flutter/material.dart';\nimport '../models/task_model.dart';\n\nclass TaskDetailScreen extends StatelessWidget {\n  final TaskModel task;\n\n  const TaskDetailScreen({super.key, required this.task});\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(title: Text(task.title)),\n      body: Padding(\n        padding: const EdgeInsets.all(24.0),\n        child: Column(\n          crossAxisAlignment: CrossAxisAlignment.start,\n          children: [\n            Text('Priority: \${task.priority.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),\n            const SizedBox(height: 12),\n            Text(task.description, style: const TextStyle(fontSize: 16)),\n          ],\n        ),\n      ),\n    );\n  }\n}",
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      FileNode(
        name: 'pubspec.yaml',
        content: 'name: sync_tasks\ndescription: A robust To-Do application for cross-device productivity.\npublish_to: "none"\nversion: 1.0.0+1\n\nenvironment:\n  sdk: ">=3.0.0 <4.0.0"\n\ndependencies:\n  flutter:\n    sdk: flutter\n  provider: ^6.1.1\n  shared_preferences: ^2.2.2\n  intl: ^0.19.0',
      ),
      FileNode(
        name: 'README.md',
        content: '# SyncTasks 🔥\n\nA robust To-Do application for cross-device productivity. SyncTasks allows users to manage their daily schedules with real-time cloud synchronization between mobile and desktop.\n\n## Architecture\n- **Pattern**: MVVM (Model-View-ViewModel)\n- **State Management**: Provider\n- **Persistence**: Shared Preferences & Cloud Sync Engine',
      ),
    ];
  }

  void startDevelopment() async {
    await DevLogger.startNewSession();
    DevLogger.log('WorkspaceViewModel: startDevelopment called');
    if (_isDeveloping) {
      DevLogger.log('WorkspaceViewModel: Already developing, ignoring');
      return;
    }
    
    if (_project.developmentPlan == null || _project.developmentPlan!.phases.isEmpty) {
      DevLogger.log('WorkspaceViewModel: Development plan is empty, generating default');
      _generateDefaultPlan();
    } else {
      DevLogger.log('WorkspaceViewModel: Using existing plan with ${_project.developmentPlan!.phases.length} phases');
    }

    if (_isLocalAiMode && !_isModelReady) {
      DevLogger.log('WorkspaceViewModel: 🛡️ LOCAL AI GATING ACTIVE. Checking model...');
      final actuallyReady = await _downloaderService.isModelDownloaded();
      if (!actuallyReady) {
        DevLogger.log('WorkspaceViewModel: Model not ready. Initiating/Resuming download.');
        downloadModel();
        return;
      } else {
        DevLogger.log('WorkspaceViewModel: Model verified on disk. Proceeding.');
        _isModelReady = true;
      }
    }

    _isDeveloping = true;
    _project = _project.copyWith(status: ProjectStatus.inProgress);
    DevLogger.log('WorkspaceViewModel: Notifying listeners (Development Started)');
    notifyListeners();

    try {
      while (_isDeveloping) {
        DevLogger.log('WorkspaceViewModel: Looking for next task...');
        final nextTask = _getNextPendingTask();
        
        if (nextTask == null) {
          DevLogger.log('WorkspaceViewModel: No more pending tasks. Development complete.');
          _isDeveloping = false;
          _project = _project.copyWith(status: ProjectStatus.completed);
          break;
        }

        DevLogger.log('WorkspaceViewModel: Next task identified: ${nextTask.title} (${nextTask.id})');
        final agent = _assignAgentForTask(nextTask);
        final role = _assignRoleForTask(nextTask);
        final taskWithRole = nextTask.copyWith(role: role);
        
        DevLogger.log('WorkspaceViewModel: Assigned agent ${agent.name} (${agent.type}) with role: $role');
        
        DevLogger.log('WorkspaceViewModel: Starting stream for task ${nextTask.id}...');
        final existingFilePaths = _getAllFilePaths(_virtualFileSystem, '');
        
        await for (final execution in _executionService.executeTask(
          taskWithRole,
          agent,
          project: _project,
          existingFiles: existingFilePaths,
          isLocalMode: _isLocalAiMode,
        )) {
          if (!_isDeveloping) {
            DevLogger.log('WorkspaceViewModel: Development stopped by user mid-task');
            break;
          }
          DevLogger.log('WorkspaceViewModel: Execution Update: ${execution.status}');
          _activeExecution = execution;
          notifyListeners();
        }

        DevLogger.log('WorkspaceViewModel: Stream finished for task ${nextTask.id}');
        if (_activeExecution?.status == ExecutionStatus.completed) {
          DevLogger.log('WorkspaceViewModel: Marking task ${nextTask.id} as DONE');
          _markTaskAsDone(nextTask.id);
          
          if (_activeExecution?.result is CodingResult) {
            DevLogger.log('WorkspaceViewModel: Applying real file generation for task ${nextTask.id}');
            _applyCodingResult(_activeExecution!.result as CodingResult, task: nextTask, agent: agent);
          } else {
            DevLogger.log('WorkspaceViewModel: No coding result found, falling back to simulation');
            _simulateFileGeneration(nextTask);
          }
        } else {
          DevLogger.log('WorkspaceViewModel: Task ${nextTask.id} failed or did not return completed result. Marking done and proceeding...');
          _markTaskAsDone(nextTask.id);
        }
      }
    } catch (e, stackTrace) {
      DevLogger.log('WorkspaceViewModel: CRITICAL ERROR during development loop: $e');
      DevLogger.log('WorkspaceViewModel: StackTrace: $stackTrace');
      _isDeveloping = false;
    } finally {
      DevLogger.log('WorkspaceViewModel: Development loop exited. Cleaning up...');
      _isDeveloping = false;
      _activeExecution = null;
      notifyListeners();
    }
  }

  List<String> _getAllFilePaths(List<FileNode> nodes, String currentPath) {
    List<String> paths = [];
    for (final node in nodes) {
      final nodePath = currentPath.isEmpty ? node.name : '$currentPath/${node.name}';
      if (node.isFolder) {
        paths.addAll(_getAllFilePaths(node.children ?? [], nodePath));
      } else {
        paths.add(nodePath);
      }
    }
    return paths;
  }

  void _applyCodingResult(CodingResult result, {required Task task, required Agent agent}) {
    DevLogger.log('WorkspaceViewModel: Applying ${result.changes.length} file changes');
    final newFileChanges = List<FileChange>.from(_project.fileChanges);

    for (final change in result.changes) {
      DevLogger.log('WorkspaceViewModel: Processing [${change.type}] ${change.path}');
      if (change.type == 'delete') {
        _removeFileFromSystem(change.path);
      } else {
        _addOrUpdateFileInSystem(change.path, change.content);
      }

      FileChangeType changeType = FileChangeType.modified;
      if (change.type == 'create') {
        changeType = FileChangeType.created;
      } else if (change.type == 'delete') {
        changeType = FileChangeType.deleted;
      }

      newFileChanges.add(
        FileChange(
          id: 'fc_${DateTime.now().millisecondsSinceEpoch}_${newFileChanges.length}',
          filePath: change.path,
          type: changeType,
          agentName: agent.name,
          taskTitle: task.title,
          timestamp: DateTime.now(),
        ),
      );
    }

    _project = _project.copyWith(fileChanges: newFileChanges);
    notifyListeners();
  }

  void _addOrUpdateFileInSystem(String path, String content) {
    DevLogger.log('WorkspaceViewModel: VFS Update - Path: $path');
    final parts = path.split('/');
    List<FileNode> currentLevel = _virtualFileSystem;
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final isLast = i == parts.length - 1;
      
      final existingIndex = currentLevel.indexWhere((n) => n.name == part);
      
      if (isLast) {
        if (existingIndex != -1) {
          DevLogger.log('WorkspaceViewModel: Updating existing file: $part');
          final oldNode = currentLevel[existingIndex];
          currentLevel[existingIndex] = FileNode(
            name: part,
            content: content,
            isFolder: false,
            isExpanded: oldNode.isExpanded,
          );
        } else {
          DevLogger.log('WorkspaceViewModel: Creating new file: $part');
          currentLevel.add(FileNode(name: part, content: content));
        }
      } else {
        if (existingIndex != -1) {
          if (!currentLevel[existingIndex].isFolder) {
            DevLogger.log('WorkspaceViewModel: Error - $part exists but is not a folder');
            return;
          }
          currentLevel = currentLevel[existingIndex].children!;
        } else {
          DevLogger.log('WorkspaceViewModel: Creating new folder: $part');
          final newFolder = FileNode(name: part, isFolder: true, children: [], isExpanded: true);
          currentLevel.add(newFolder);
          currentLevel = newFolder.children!;
        }
      }
    }
  }

  void _removeFileFromSystem(String path) {
    final parts = path.split('/');
    List<FileNode> currentLevel = _virtualFileSystem;
    
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final isLast = i == parts.length - 1;
      
      final existingIndex = currentLevel.indexWhere((n) => n.name == part);
      if (existingIndex == -1) return;
      
      if (isLast) {
        currentLevel.removeAt(existingIndex);
      } else {
        if (!currentLevel[existingIndex].isFolder) return;
        currentLevel = currentLevel[existingIndex].children!;
      }
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

    // Define a default architecture if missing
    final defaultArchitecture = Architecture(
      pattern: ArchitecturePattern.mvvm,
      layers: ['Presentation', 'Domain', 'Data'],
      modules: [
        const Module(name: 'Core', responsibility: 'Shared logic and utilities'),
        const Module(name: 'Features', responsibility: 'App functional modules'),
      ],
    );

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
    _project = _project.copyWith(
      developmentPlan: dummyPlan,
      architecture: _project.architecture ?? defaultArchitecture,
    );
    notifyListeners();
  }

  void stopDevelopment() {
    _isDeveloping = false;
    notifyListeners();
  }

  void runBuild(String platform) {
    DevLogger.log('WorkspaceViewModel: Triggering build for platform $platform');
    final newBuilds = List<ProjectBuild>.from(_project.builds);
    newBuilds.add(
      ProjectBuild(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        platform: platform,
        status: BuildStatus.successful,
        progress: 1.0,
        startedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        completedAt: DateTime.now(),
        artifact: BuildArtifact(
          name: '${_project.name.toLowerCase()}-$platform.apk',
          size: '24.5 MB',
          type: platform.toUpperCase(),
          downloadUrl: '#',
        ),
      ),
    );
    _project = _project.copyWith(builds: newBuilds);
    notifyListeners();
  }

  void runTests() {
    DevLogger.log('WorkspaceViewModel: Running QA test suite');
    final newTestRuns = List<TestRun>.from(_project.testRuns);
    newTestRuns.add(
      TestRun(
        id: 'tr_${DateTime.now().millisecondsSinceEpoch}',
        category: TestCategory.unit,
        status: TestStatus.passed,
        startedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        completedAt: DateTime.now(),
        totalCount: 15,
        passedCount: 15,
        failedCount: 0,
        skippedCount: 0,
        coverage: 0.92,
        testCases: const [
          TestCase(
            id: 'tc1',
            name: 'Theme Tokens Initialization',
            suite: 'core/theme_test.dart',
            status: TestStatus.passed,
            duration: Duration(milliseconds: 140),
            logs: ['Checking light theme...', 'Checking dark theme...', 'Pass.'],
            relatedFiles: ['lib/core/theme/app_theme.dart'],
          ),
          TestCase(
            id: 'tc2',
            name: 'SyncEngine Initialization',
            suite: 'core/services/sync_engine_test.dart',
            status: TestStatus.passed,
            duration: Duration(milliseconds: 210),
            logs: ['Verifying cloud connection...', 'Pass.'],
            relatedFiles: ['lib/core/services/sync_engine.dart'],
          ),
        ],
      ),
    );
    _project = _project.copyWith(testRuns: newTestRuns);
    notifyListeners();
  }

  void generateArtifacts() {
    DevLogger.log('WorkspaceViewModel: Generating project artifacts');
    final newArtifacts = List<ProjectArtifact>.from(_project.artifacts);
    final now = DateTime.now();
    newArtifacts.addAll([
      ProjectArtifact(
        id: 'art_src_${now.millisecondsSinceEpoch}',
        name: 'Source Code Bundle',
        type: ArtifactType.sourceCode,
        generatedAt: now,
        status: ArtifactStatus.current,
        size: '1.8 MB',
      ),
      ProjectArtifact(
        id: 'art_arch_${now.millisecondsSinceEpoch}',
        name: 'Technical Architecture Blueprint',
        type: ArtifactType.architecture,
        generatedAt: now,
        status: ArtifactStatus.current,
        size: '420 KB',
      ),
      ProjectArtifact(
        id: 'art_test_${now.millisecondsSinceEpoch}',
        name: 'QA Test Execution Report',
        type: ArtifactType.testReport,
        generatedAt: now,
        status: ArtifactStatus.current,
        size: '850 KB',
      ),
    ]);
    _project = _project.copyWith(artifacts: newArtifacts);
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
    // Determine agent based on the task description or title
    final title = task.title.toLowerCase();
    final desc = task.description.toLowerCase();
    
    if (title.contains('setup') || title.contains('bootstrap') || title.contains('initialize') || 
        desc.contains('create project') || desc.contains('directory structure')) {
      return _agents.firstWhere((a) => a.type == AgentType.developer, orElse: () => _agents[3]); // Coding Agent
    }

    if (title.contains('ui') || title.contains('screen') || title.contains('crud') || title.contains('feature') ||
        desc.contains('implement') || desc.contains('logic') || desc.contains('code')) {
      return _agents.firstWhere((a) => a.type == AgentType.developer, orElse: () => _agents[3]); // Coding Agent
    }

    if (title.contains('test') || desc.contains('verify')) {
      return _agents.firstWhere((a) => a.type == AgentType.tester, orElse: () => _agents[4]); // Testing Agent
    }

    if (task.phaseId == 'p1' || task.phaseId == 'p2') {
      return _agents.firstWhere((a) => a.type == AgentType.architect, orElse: () => _agents[2]); // Architecture
    }
    
    return _agents[3]; // Default to Coding Agent
  }

  String _assignRoleForTask(Task task) {
    final title = task.title.toLowerCase();
    final desc = task.description.toLowerCase();

    if (title.contains('ui') || title.contains('screen') || title.contains('widget')) return 'UI';
    if (title.contains('entity') || title.contains('model') || desc.contains('domain')) return 'DOMAIN';
    if (title.contains('repository') || title.contains('data') || title.contains('api')) return 'DATA';
    if (title.contains('integration') || title.contains('wire') || title.contains('initialize')) return 'INTEGRATION';

    return 'UI'; // Default to UI for coding tasks
  }

  void _markTaskAsDone(String taskId) {
    DevLogger.log('WorkspaceViewModel: _markTaskAsDone called for task $taskId');
    final plan = _project.developmentPlan;
    if (plan == null) {
      DevLogger.log('WorkspaceViewModel: Error - plan is null in _markTaskAsDone');
      return;
    }

    final updatedPhases = plan.phases.map((phase) {
      final updatedTasks = phase.tasks.map((task) {
        if (task.id == taskId) {
          DevLogger.log('WorkspaceViewModel: Setting task $taskId status to DONE');
          return task.copyWith(status: TaskStatus.done);
        }
        return task;
      }).toList();
      return phase.copyWith(tasks: updatedTasks);
    }).toList();

    final updatedPlan = plan.copyWith(phases: updatedPhases);
    _project = _project.copyWith(developmentPlan: updatedPlan);
    DevLogger.log('WorkspaceViewModel: Project updated. Notifying listeners.');
    notifyListeners();
  }
}

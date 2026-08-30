import 'package:flutter/foundation.dart';
import '../../project/models/project.dart';
import '../../project/models/agent.dart';
import '../../project/models/agent_execution.dart';
import '../../project/models/task.dart';
import '../../../core/services/agent_simulator_service.dart';

class WorkspaceViewModel extends ChangeNotifier {
  final AgentExecutionService _executionService;
  
  Project _project;
  Project get project => _project;
  
  bool _isDeveloping = false;
  bool get isDeveloping => _isDeveloping;
  
  AgentExecution? _activeExecution;
  AgentExecution? get activeExecution => _activeExecution;
  
  final List<Agent> _agents = [
    const Agent(id: 'a1', name: 'Discovery Agent', type: AgentType.manager, description: 'Understands ideas.'),
    const Agent(id: 'a2', name: 'Product Agent', type: AgentType.manager, description: 'Formalizes requirements.'),
    const Agent(id: 'a3', name: 'Architecture Agent', type: AgentType.architect, description: 'Blueprints system.'),
    const Agent(id: 'a4', name: 'Coding Agent', type: AgentType.developer, description: 'Writes code.'),
    const Agent(id: 'a5', name: 'Testing Agent', type: AgentType.tester, description: 'Ensures quality.'),
  ];
  
  List<Agent> get agents => _agents;
  
  WorkspaceViewModel(this._project, this._executionService);

  void startDevelopment() async {
    if (_isDeveloping) return;
    _isDeveloping = true;
    notifyListeners();

    while (_isDeveloping) {
      final nextTask = _getNextPendingTask();
      if (nextTask == null) {
        _isDeveloping = false;
        break;
      }

      final agent = _assignAgentForTask(nextTask);
      
      await for (final execution in _executionService.executeTask(nextTask, agent)) {
        _activeExecution = execution;
        notifyListeners();
      }

      if (_activeExecution?.status == ExecutionStatus.completed) {
        _markTaskAsDone(nextTask.id);
      } else {
        _isDeveloping = false; // Stop on failure (simulated for now)
      }
    }
    
    _isDeveloping = false;
    _activeExecution = null;
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
    final plan = _project.developmentPlan;
    if (plan == null) return;

    final updatedPhases = plan.phases.map((phase) {
      final updatedTasks = phase.tasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(status: TaskStatus.done);
        }
        return task;
      }).toList();
      return phase.copyWith(tasks: updatedTasks);
    }).toList();

    final updatedPlan = plan.copyWith(phases: updatedPhases);
    _project = _project.copyWith(developmentPlan: updatedPlan);
    notifyListeners();
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../features/project/models/agent.dart';
import '../../features/project/models/agent_execution.dart';
import '../../features/project/models/task.dart';

import '../../features/project/models/project.dart';

abstract class AgentExecutionService {
  Stream<AgentExecution> executeTask(
    Task task,
    Agent agent, {
    required Project project,
    List<String> existingFiles = const [],
    bool isLocalMode = false,
  });
}

class AgentSimulatorService implements AgentExecutionService {
  final _random = Random();

  @override
  Stream<AgentExecution> executeTask(
    Task task,
    Agent agent, {
    required Project project,
    List<String> existingFiles = const [],
    bool isLocalMode = false,
  }) async* {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    debugPrint('[$timestamp] AgentSimulator: Starting task ${task.id} with agent ${agent.name}');
    final executionId = 'exec_${DateTime.now().millisecondsSinceEpoch}';
    final startedAt = DateTime.now();
    
    // 1. Initializing / Planning
    yield AgentExecution(
      id: executionId,
      agentId: agent.id,
      taskId: task.id,
      status: ExecutionStatus.planning,
      startedAt: startedAt,
      logs: [
        ExecutionLog(
          timestamp: DateTime.now(),
          message: 'Agent ${agent.name} assigned to task: ${task.title}',
          details: 'Context loaded. Analyzing requirements...',
        ),
      ],
    );

    await Future.delayed(const Duration(milliseconds: 800)); // Reduced delay

    // 2. Running
    List<ExecutionLog> logs = [
      ExecutionLog(
        timestamp: DateTime.now(),
        message: 'Starting execution...',
        details: 'Generating files: ${task.filesToChange.isNotEmpty ? task.filesToChange.join(", ") : "project structure"}',
      ),
    ];

    for (int i = 1; i <= 3; i++) { // Reduced steps from 5 to 3
      await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
      
      logs.add(ExecutionLog(
        timestamp: DateTime.now(),
        message: 'Step $i/3 in progress...',
        details: 'Processing ${task.title} sub-components.',
      ));

      yield AgentExecution(
        id: executionId,
        agentId: agent.id,
        taskId: task.id,
        status: ExecutionStatus.running,
        startedAt: startedAt,
        logs: List.from(logs),
      );
    }

    // 3. Completing
    await Future.delayed(const Duration(milliseconds: 500));
    logs.add(ExecutionLog(
      timestamp: DateTime.now(),
      message: 'Task completed successfully.',
      details: 'All acceptance criteria met. Changes staged for commit.',
    ));

    yield AgentExecution(
      id: executionId,
      agentId: agent.id,
      taskId: task.id,
      status: ExecutionStatus.completed,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      logs: logs,
    );
    debugPrint('[$timestamp] AgentSimulator: Completed task ${task.id}');
  }
}

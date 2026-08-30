import 'dart:async';
import 'dart:math';
import '../../features/project/models/agent.dart';
import '../../features/project/models/agent_execution.dart';
import '../../features/project/models/task.dart';

abstract class AgentExecutionService {
  Stream<AgentExecution> executeTask(Task task, Agent agent);
}

class AgentSimulatorService implements AgentExecutionService {
  final _random = Random();

  @override
  Stream<AgentExecution> executeTask(Task task, Agent agent) async* {
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

    await Future.delayed(const Duration(seconds: 2));

    // 2. Running
    List<ExecutionLog> logs = [
      ExecutionLog(
        timestamp: DateTime.now(),
        message: 'Starting execution...',
        details: 'Generating files: ${task.filesToChange.join(", ")}',
      ),
    ];

    for (int i = 1; i <= 5; i++) {
      await Future.delayed(Duration(seconds: 1 + _random.nextInt(2)));
      
      logs.add(ExecutionLog(
        timestamp: DateTime.now(),
        message: 'Step $i/5 in progress...',
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
    await Future.delayed(const Duration(seconds: 1));
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
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/project/models/agent.dart';
import '../../features/project/models/agent_execution.dart';
import '../../features/project/models/task.dart';
import '../../features/project/models/project.dart';
import '../../features/project/models/coding_result.dart';
import '../constants/app_constants.dart';
import 'agent_simulator_service.dart';

class BackendAgentService implements AgentExecutionService {
  final http.Client _client;

  BackendAgentService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Stream<AgentExecution> executeTask(
    Task task,
    Agent agent, {
    required Project project,
    List<String> existingFiles = const [],
  }) async* {
    final executionId = 'exec_${DateTime.now().millisecondsSinceEpoch}';
    final startedAt = DateTime.now();

    // 1. Planning State
    yield AgentExecution(
      id: executionId,
      agentId: agent.id,
      taskId: task.id,
      status: ExecutionStatus.planning,
      startedAt: startedAt,
      logs: [
        ExecutionLog(
          timestamp: DateTime.now(),
          message: 'Connecting to Kindle Backend...',
          details: 'Initializing context for project: ${project.name}',
        ),
      ],
    );

    try {
      // 2. Running State - Making the real API call
      yield AgentExecution(
        id: executionId,
        agentId: agent.id,
        taskId: task.id,
        status: ExecutionStatus.running,
        startedAt: startedAt,
        logs: [
          ExecutionLog(
            timestamp: DateTime.now(),
            message: 'Agent ${agent.name} is working...',
            details: 'Sending request to backend coding agent.',
          ),
        ],
      );

      final response = await _client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/coding/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'projectId': project.id,
          'task': task.toMap(),
          'architecture': project.architecture?.toMap(),
          'existingFiles': existingFiles,
        }),
      ).timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final codingResult = CodingResult.fromMap(data);

        yield AgentExecution(
          id: executionId,
          agentId: agent.id,
          taskId: task.id,
          status: ExecutionStatus.completed,
          startedAt: startedAt,
          completedAt: DateTime.now(),
          result: codingResult,
          logs: [
            ExecutionLog(
              timestamp: DateTime.now(),
              message: 'Code generation successful!',
              details: codingResult.explanation,
            ),
          ],
        );
      } else {
        String errorMessage = 'Backend failed with status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('BackendAgentService: Error executing task: $e');
      yield AgentExecution(
        id: executionId,
        agentId: agent.id,
        taskId: task.id,
        status: ExecutionStatus.failed,
        startedAt: startedAt,
        completedAt: DateTime.now(),
        logs: [
          ExecutionLog(
            timestamp: DateTime.now(),
            message: 'Execution failed',
            details: e.toString(),
            level: 'error',
          ),
        ],
      );
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/project/models/agent.dart';
import '../../features/project/models/agent_execution.dart';
import '../../features/project/models/task.dart';
import '../../features/project/models/project.dart';
import '../../features/project/models/coding_result.dart';
import '../constants/app_constants.dart';
import 'agent_simulator_service.dart';
import 'local_inference_service.dart';
import 'model_downloader_service.dart';

class BackendAgentService implements AgentExecutionService {
  final http.Client _client;
  final LocalInferenceService _localInference = LocalInferenceService();
  final ModelDownloaderService _downloader = ModelDownloaderService();

  BackendAgentService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Stream<AgentExecution> executeTask(
    Task task,
    Agent agent, {
    required Project project,
    List<String> existingFiles = const [],
    bool isLocalMode = false,
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
            details: 'Opening stream to backend coding agent.',
          ),
        ],
      );

      final request = http.Request(
        'POST',
        Uri.parse('${AppConstants.apiBaseUrl}/coding/execute'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'projectId': project.id,
        'task': task.toMap(),
        'architecture': project.architecture?.toMap(),
        'existingFiles': existingFiles,
        'isLocalMode': isLocalMode,
      });

      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode == 200) {
        String buffer = '';
        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
          buffer += chunk;
          
          // Process SSE lines
          final lines = buffer.split('\n');
          // Keep the last partial line in the buffer
          buffer = lines.removeLast();

          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6).trim();
              if (dataStr.isEmpty) continue;

              final data = jsonDecode(dataStr);
              final type = data['type'];
              final content = data['content'];

              if (type == 'chunk') {
                // In a real UI, we might want to yield a progress update here
                // For now, we just keep the stream alive
              } else if (type == 'result') {
                final codingResult = CodingResult.fromMap(content);
                
                if (content['promptDelegation'] != null) {
                  // Handle client-side generation
                  final delegation = content['promptDelegation'];
                  yield* _handleLocalGeneration(
                    executionId, 
                    agent, 
                    task, 
                    startedAt, 
                    delegation['systemPrompt'], 
                    delegation['userPrompt']
                  );
                } else {
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
                }
              } else if (type == 'error') {
                throw Exception(data['message']);
              }
            }
          }
        }
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        String errorMessage = 'Backend failed with status: ${streamedResponse.statusCode}';
        try {
          final errorData = jsonDecode(errorBody);
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
  Stream<AgentExecution> _handleLocalGeneration(
    String executionId,
    Agent agent,
    Task task,
    DateTime startedAt,
    String systemPrompt,
    String userPrompt,
  ) async* {
    yield AgentExecution(
      id: executionId,
      agentId: agent.id,
      taskId: task.id,
      status: ExecutionStatus.running,
      startedAt: startedAt,
      logs: [
        ExecutionLog(
          timestamp: DateTime.now(),
          message: 'Delegating to local AI engine...',
          details: 'Prompt received from backend. Running on-device inference.',
        ),
      ],
    );

    if (!kIsWeb) {
      final modelPath = await _downloader.getModelPath();
      await _localInference.initialize(modelPath);
    }

    String resultString = '';
    await for (final token in _localInference.generate(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    )) {
      resultString += token;
      // You could yield chunks here if the UI supported it
    }

    try {
      final resultMap = jsonDecode(resultString);
      final codingResult = CodingResult.fromMap(resultMap);

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
            message: 'Local code generation complete!',
            details: codingResult.explanation,
          ),
        ],
      );
    } catch (e) {
      throw Exception('Failed to parse local AI output: $e');
    }
  }
}

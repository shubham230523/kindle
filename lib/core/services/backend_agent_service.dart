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
                if (content['promptDelegation'] != null) {
                  // Handle client-side generation
                  final delegation = content['promptDelegation'];
                  yield* _handleLocalGeneration(
                    executionId, 
                    agent, 
                    task, 
                    startedAt, 
                    delegation['systemPrompt'], 
                    delegation['userPrompt'],
                    isCodingTask: true
                  );
                } else {
                  final codingResult = CodingResult.fromMap(content);
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
  }

  Stream<AgentExecution> _handleLocalGeneration(
    String executionId,
    Agent agent,
    Task task,
    DateTime startedAt,
    String systemPrompt,
    String userPrompt, {
    bool isCodingTask = false,
  }) async* {
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
    }

    try {
      // Attempt to find the first valid JSON block in the output
      String jsonContent = resultString;
      final start = resultString.indexOf('{');
      if (start != -1) {
        int depth = 0;
        int end = -1;
        for (int i = start; i < resultString.length; i++) {
          if (resultString[i] == '{') depth++;
          else if (resultString[i] == '}') depth--;
          
          if (depth == 0) {
            end = i;
            break;
          }
        }
        if (end != -1) {
          jsonContent = resultString.substring(start, end + 1);
        }
      }

      final resultMap = jsonDecode(_sanitizeJson(jsonContent));
      final dynamic finalResult = isCodingTask ? CodingResult.fromMap(resultMap) : resultMap;
      
      yield AgentExecution(
        id: executionId,
        agentId: agent.id,
        taskId: task.id,
        status: ExecutionStatus.completed,
        startedAt: startedAt,
        completedAt: DateTime.now(),
        result: finalResult,
        logs: [
          ExecutionLog(
            timestamp: DateTime.now(),
            message: 'Local execution complete!',
            details: resultMap['explanation'] ?? 'Successful on-device inference.',
          ),
        ],
      );
    } catch (e) {
      debugPrint('Local AI Decode Error: $e\nRaw content: $resultString');
      throw Exception('Failed to parse local AI output: $e');
    }
  }

  String _sanitizeJson(String input) {
    // 1. Remove markdown code block markers
    input = input.replaceAll('```json', '').replaceAll('```', '');

    // 2. Handle Dart raw string markers: r""" ... """ and r" ... "
    input = input.replaceAllMapped(RegExp(r'r"""([\s\S]*?)"""'), (m) => jsonEncode(m.group(1)));
    input = input.replaceAllMapped(RegExp(r'r"([\s\S]*?)"'), (m) => jsonEncode(m.group(1)));
    
    // 3. Handle standard triple quotes: """ ... """
    input = input.replaceAllMapped(RegExp(r'"""([\s\S]*?)"""'), (m) => jsonEncode(m.group(1)));

    // 4. Handle literal newlines inside double-quoted values.
    // We look for : followed by " and then a block that contains newlines
    // and ends with " followed by a comma, brace, or bracket.
    final jsonValuePattern = RegExp(r':\s*"([\s\S]*?)"\s*(?=[,\]}])');
    input = input.replaceAllMapped(jsonValuePattern, (match) {
      final value = match.group(1) ?? '';
      if (value.contains('\n') || value.contains('\r')) {
        // Encode properly to escape newlines, quotes, etc.
        return ': ' + jsonEncode(value);
      }
      return match.group(0)!;
    });

    // 5. Remove trailing commas in objects/arrays
    input = input.replaceAllMapped(RegExp(r',\s*([\]}])'), (match) => match.group(1)!);

    return input;
  }
}

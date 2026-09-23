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
import 'local_inference_service.dart';
import 'model_downloader_service.dart';
import '../utils/dev_logger.dart';

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
      DevLogger.log('BackendAgentService: Error executing task: $e');
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
    if (kIsWeb) {
      throw UnsupportedError('Local AI inference is not supported on the Web platform.');
    }

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
      final resultMap = _extractAndParseJson(resultString);
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
      DevLogger.log('Local AI Decode Error: $e\nRaw content: $resultString');
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
            message: 'Local execution failed to parse JSON',
            details: e.toString(),
            level: 'error',
          ),
        ],
      );
    }
  }

  Map<String, dynamic> _extractAndParseJson(String rawOutput) {
    if (rawOutput.trim().isEmpty) {
      throw const FormatException('Empty raw output from AI model');
    }

    // 1. Clean markdown code fences and external text
    String cleaned = rawOutput.replaceAll('```json', '').replaceAll('```', '').trim();

    // 2. Find opening brace '{'
    final start = cleaned.indexOf('{');
    if (start == -1) {
      throw FormatException('No opening brace "{" found in output');
    }

    cleaned = cleaned.substring(start);

    // 3. String-aware JSON block extraction
    int depth = 0;
    bool inString = false;
    bool escaped = false;
    int end = -1;

    for (int i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (char == '\\') {
        escaped = true;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        continue;
      }
      if (!inString) {
        if (char == '{') {
          depth++;
        } else if (char == '}') {
          depth--;
        }

        if (depth == 0) {
          end = i;
          break;
        }
      }
    }

    if (end != -1) {
      cleaned = cleaned.substring(0, end + 1);
    }

    // 4. Sanitize literal control chars (newlines, tabs, carriage returns inside strings)
    StringBuffer buffer = StringBuffer();
    inString = false;
    escaped = false;

    for (int i = 0; i < cleaned.length; i++) {
      String char = cleaned[i];
      if (inString) {
        if (escaped) {
          buffer.write(char);
          escaped = false;
        } else if (char == '\\') {
          buffer.write(char);
          escaped = true;
        } else if (char == '"') {
          buffer.write(char);
          inString = false;
        } else if (char == '\n') {
          buffer.write('\\n');
        } else if (char == '\r') {
          buffer.write('\\r');
        } else if (char == '\t') {
          buffer.write('\\t');
        } else {
          buffer.write(char);
        }
      } else {
        if (char == '"') {
          inString = true;
        }
        buffer.write(char);
      }
    }

    String jsonString = buffer.toString();

    // 5. Handle Dart raw strings
    jsonString = jsonString.replaceAllMapped(RegExp(r'r"""([\s\S]*?)"""'), (m) {
      return jsonEncode(m.group(1)!);
    });
    jsonString = jsonString.replaceAllMapped(RegExp(r'r"([\s\S]*?)"'), (m) {
      return jsonEncode(m.group(1)!);
    });
    jsonString = jsonString.replaceAllMapped(RegExp(r'"""([\s\S]*?)"""'), (m) {
      return jsonEncode(m.group(1)!);
    });

    // 6. Remove trailing commas
    jsonString = jsonString.replaceAllMapped(RegExp(r',\s*([\]}])'), (m) {
      return m.group(1)!;
    });

    // 7. Emergency repair for unclosed JSON
    if (!jsonString.endsWith('}')) {
      if (jsonString.split('"').length % 2 == 0) {
        jsonString += '"';
      }
      final openBraces = '{'.allMatches(jsonString).length;
      final closeBraces = '}'.allMatches(jsonString).length;
      final openBrackets = '['.allMatches(jsonString).length;
      final closeBrackets = ']'.allMatches(jsonString).length;

      int curBrackets = closeBrackets;
      int curBraces = closeBraces;
      final sb = StringBuffer(jsonString);
      for (int i = curBrackets; i < openBrackets; i++) {
        sb.write(']');
      }
      for (int i = curBraces; i < openBraces; i++) {
        sb.write('}');
      }
      jsonString = sb.toString();
    }

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      try {
        final pattern = RegExp(r'("content"\s*:\s*")([\s\S]*?)("\s*,\s*"type")');
        final recovered = jsonString.replaceAllMapped(pattern, (Match m) {
          final prefix = m.group(1)!;
          final codeContent = m.group(2)!.replaceAll('"', '\\"');
          final suffix = m.group(3)!;
          return '$prefix$codeContent$suffix';
        });
        return jsonDecode(recovered) as Map<String, dynamic>;
      } catch (_) {
        throw FormatException('Failed to decode JSON: $e');
      }
    }
  }
}

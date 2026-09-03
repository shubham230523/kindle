import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalInferenceService {
  bool _isInitialized = false;
  LlamaEngine? _engine;

  Future<void> initialize(String modelPath) async {
    if (_isInitialized) return;
    
    // Normalize path for Windows
    final normalizedPath = Platform.isWindows ? modelPath.replaceAll('/', '\\') : modelPath;
    
    debugPrint('LocalInferenceService: Initializing with model at $normalizedPath');
    try {
      _engine = await LlamaEngine.spawn(
        modelParams: ModelParams(
          path: normalizedPath,
          gpuLayers: 0, // Force CPU to avoid Windows GPU driver issues
        ),
        contextParams: const ContextParams(
          nCtx: 2048,
        ),
      );
      
      _isInitialized = true;
      debugPrint('LocalInferenceService: ✅ AI Engine Initialized');
    } catch (e) {
      debugPrint('LocalInferenceService: ❌ Initialization Error: $e');
      rethrow;
    }
  }

  Stream<String> generate({
    required String systemPrompt,
    required String userPrompt,
  }) async* {
    if (!_isInitialized || _engine == null) throw Exception('Local AI Engine not initialized');

    debugPrint('LocalInferenceService: 🧠 STARTING ON-DEVICE INFERENCE');

    try {
      final chat = await _engine!.createChat();
      chat.addSystem(systemPrompt);
      chat.addUser(userPrompt);
      
      await for (final event in chat.generate(maxTokens: 2048)) {
        if (event is TokenEvent) {
          if (event.text.isNotEmpty) {
            yield event.text;
          }
        } else if (event is DoneEvent) {
          debugPrint('LocalInferenceService: ✅ Generation complete');
          break;
        }
      }
    } catch (e) {
      debugPrint('LocalInferenceService: ❌ Error during generation: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _engine?.dispose();
    _engine = null;
    _isInitialized = false;
  }
}

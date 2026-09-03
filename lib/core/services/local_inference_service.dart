import 'dart:async';
import 'dart:io';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalInferenceService {
  bool _isInitialized = false;
  LlamaEngine? _engine;

  Future<void> initialize(String modelPath) async {
    if (_isInitialized) return;
    
    // Normalize path for Windows
    final normalizedPath = Platform.isWindows ? modelPath.replaceAll('/', '\\') : modelPath;
    
    // Manual loading into the process to resolve symbols
    if (Platform.isWindows) {
      try {
        final exeDir = File(Platform.resolvedExecutable).parent.path;
        // Load in correct order: ggml then llama
        DynamicLibrary.open('$exeDir\\ggml.dll');
        DynamicLibrary.open('$exeDir\\llama.dll');
        debugPrint('LocalInferenceService: ✅ DLLs pre-loaded into process');
      } catch (e) {
        debugPrint('LocalInferenceService: ⚠️ DLL pre-load warning: $e');
      }
    }

    debugPrint('LocalInferenceService: Initializing with model at $normalizedPath');
    try {
      // Use spawnFromProcess which looks at the already-loaded libraries in the process memory
      _engine = await LlamaEngine.spawnFromProcess(
        modelParams: ModelParams(
          path: normalizedPath,
          gpuLayers: 0,
        ),
        contextParams: const ContextParams(
          nCtx: 8192, // Increased from 2048 to allow for larger code files
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
      
      await for (final event in chat.generate(maxTokens: 8192)) {
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

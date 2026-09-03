import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalInferenceService {
  bool _isInitialized = false;
  Llama? _llama;

  Future<void> initialize(String modelPath) async {
    if (_isInitialized) return;
    
    debugPrint('LocalInferenceService: Initializing with model at $modelPath');
    try {
      // In 0.2.2, we use the Llama wrapper
      _llama = Llama(modelPath);
      _isInitialized = true;
    } catch (e) {
      debugPrint('LocalInferenceService: Failed to initialize: $e');
      rethrow;
    }
  }

  Stream<String> generate({
    required String systemPrompt,
    required String userPrompt,
  }) async* {
    if (!_isInitialized || _llama == null) throw Exception('Local AI Engine not initialized');

    debugPrint('LocalInferenceService: Starting generation with LlamaCpp...');

    final prompt = '$systemPrompt\n\nUser: $userPrompt\nAssistant:';
    
    try {
      _llama!.setPrompt(prompt);
      
      bool done = false;
      while (!done) {
        // llama_cpp_dart 0.2.2 returns a record (String, bool)
        final result = _llama!.getNext();
        final token = result.$1;
        done = result.$2;
        
        if (token.isNotEmpty) {
          yield token;
        }
        
        // Small delay to prevent blocking the thread entirely if not in isolate
        await Future.delayed(Duration.zero);
      }
    } catch (e) {
      debugPrint('LocalInferenceService: Error during generation: $e');
      rethrow;
    }
  }
}

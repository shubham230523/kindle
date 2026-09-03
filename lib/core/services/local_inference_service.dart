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

    debugPrint('LocalInferenceService: 🧠 STARTING ON-DEVICE INFERENCE');
    
    final prompt = '$systemPrompt\n\n### Instruction:\n$userPrompt\n\n### Response:\n';
    
    try {
      _llama!.setPrompt(prompt);
      
      bool done = false;
      int tokenCount = 0;
      
      while (!done) {
        final result = _llama!.getNext();
        final token = result.$1;
        done = result.$2;
        
        if (token.isNotEmpty) {
          yield token;
          tokenCount++;
        }
        
        // Safety break to prevent infinite loops with local models
        if (tokenCount > 4096) break;
        
        // Allow the UI to breathe
        await Future.delayed(Duration.zero);
      }
      debugPrint('LocalInferenceService: ✅ Generation complete ($tokenCount tokens)');
    } catch (e) {
      debugPrint('LocalInferenceService: ❌ Error during generation: $e');
      rethrow;
    }
  }
}

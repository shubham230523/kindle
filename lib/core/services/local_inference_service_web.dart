import 'dart:async';

class LocalInferenceService {
  Future<void> initialize(String modelPath) async {
    // Local inference is not supported on web
    throw UnsupportedError('Local AI inference is not supported on the Web platform.');
  }

  Stream<String> generate({
    required String systemPrompt,
    required String userPrompt,
  }) async* {
    throw UnsupportedError('Local AI inference is not supported on the Web platform.');
  }

  Future<void> dispose() async {
    // No-op on web
  }
}

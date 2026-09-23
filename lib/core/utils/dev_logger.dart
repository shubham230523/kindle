import 'dart:io';
import 'package:flutter/foundation.dart';

class DevLogger {
  static File? _logFile;

  static Future<File> get _file async {
    if (_logFile != null) return _logFile!;
    final currentDir = Directory.current.path;
    _logFile = File('$currentDir/development_run.log');
    return _logFile!;
  }

  /// Clears existing logs and starts a fresh log session
  static Future<void> startNewSession() async {
    try {
      final file = await _file;
      final header = '''
================================================================================
🚀 KINDLE DEVELOPMENT RUN LOG - ${DateTime.now().toIso8601String()}
================================================================================
''';
      await file.writeAsString(header);
      debugPrint('[DevLogger] 🧹 Cleared existing log file at: ${file.path}');
    } catch (e) {
      debugPrint('[DevLogger] Error clearing log file: $e');
    }
  }

  /// Logs a timestamped message to both console and the development_run.log file
  static void log(String message) {
    debugPrint(message);

    if (kIsWeb) return;

    _file.then((file) async {
      try {
        final timestamp = DateTime.now().toIso8601String().split('T').last;
        await file.writeAsString('[$timestamp] $message\n', mode: FileMode.append);
      } catch (_) {}
    });
  }

  /// Appends raw streamed text chunks to the log file
  static void logChunk(String chunk) {
    if (kIsWeb) return;

    _file.then((file) async {
      try {
        await file.writeAsString(chunk, mode: FileMode.append);
      } catch (_) {}
    });
  }
}

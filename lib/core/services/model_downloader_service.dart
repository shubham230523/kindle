import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DownloadProgress {
  final double progress;
  final String status;
  final bool isCompleted;
  final String? error;

  DownloadProgress({
    required this.progress,
    required this.status,
    this.isCompleted = false,
    this.error,
  });
}

class ModelDownloaderService {
  static const String _modelKey = 'kindle_ai_model_downloaded';
  static const String _modelUrl = 'https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf';
  static const String _modelFileName = 'qwen2.5-coder-1.5b.gguf';

  final Dio _dio = Dio();
  CancelToken? _cancelToken;

  Future<bool> isModelDownloaded() async {
    if (kIsWeb) return true; // Web uses browser cache via llamadart/IndexedDB
    
    final prefs = await SharedPreferences.getInstance();
    final isDownloaded = prefs.getBool(_modelKey) ?? false;
    
    if (isDownloaded) {
      // Double check if file exists
      final file = File(await getModelPath());
      return await file.exists();
    }
    return false;
  }

  Future<String> getModelPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/models/$_modelFileName';
  }

  Stream<DownloadProgress> downloadModel() {
    final controller = StreamController<DownloadProgress>();
    
    if (kIsWeb) {
      controller.add(DownloadProgress(progress: 1.0, status: 'Ready (Web Cache)', isCompleted: true));
      controller.close();
      return controller.stream;
    }

    _downloadAsync(controller);
    return controller.stream;
  }

  Future<void> _downloadAsync(StreamController<DownloadProgress> controller) async {
    try {
      final savePath = await getModelPath();
      final file = File(savePath);
      await Directory(file.parent.path).create(recursive: true);

      _cancelToken = CancelToken();
      controller.add(DownloadProgress(progress: 0.0, status: 'Starting download...'));

      await _dio.download(
        _modelUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            // Throttle progress updates to avoid lag
            if (received % (1024 * 1024) == 0 || received == total) {
              controller.add(DownloadProgress(
                progress: progress,
                status: 'Downloading: ${(progress * 100).toStringAsFixed(1)}% (${(received / (1024 * 1024)).toStringAsFixed(1)} MB)',
              ));
            }
          }
        },
        cancelToken: _cancelToken,
        deleteOnError: true,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelKey, true);

      controller.add(DownloadProgress(progress: 1.0, status: 'Download complete!', isCompleted: true));
    } catch (e) {
      if (CancelToken.isCancel(e as DioException)) {
        controller.add(DownloadProgress(progress: 0.0, status: 'Download canceled'));
      } else {
        controller.add(DownloadProgress(progress: 0.0, status: 'Download failed', error: e.toString()));
      }
    } finally {
      controller.close();
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
  }
}

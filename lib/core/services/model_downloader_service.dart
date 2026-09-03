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

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10), // Long timeout for large files
  ));
  CancelToken? _cancelToken;

  Future<bool> isModelDownloaded() async {
    debugPrint('ModelDownloaderService: Checking model status...');
    if (kIsWeb) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final isDownloaded = prefs.getBool(_modelKey) ?? false;
    
    final savePath = await getModelPath();
    final file = File(savePath);
    final exists = await file.exists();
    
    debugPrint('ModelDownloaderService: Prefs said $isDownloaded, File exists: $exists');
    
    if (isDownloaded && exists) {
      // Basic size check to ensure it's not a 0-byte corrupted file
      final length = await file.length();
      debugPrint('ModelDownloaderService: Model file size: ${(length / (1024 * 1024)).toStringAsFixed(1)} MB');
      return length > 100 * 1024 * 1024; // Must be at least 100MB
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
      debugPrint('ModelDownloaderService: Preparing to download to $savePath');
      
      await Directory(file.parent.path).create(recursive: true);

      // Clean up any corrupted/partial file from previous failed attempts
      if (await file.exists()) {
        debugPrint('ModelDownloaderService: Existing file found, deleting to start fresh.');
        await file.delete();
      }

      _cancelToken = CancelToken();
      controller.add(DownloadProgress(progress: 0.0, status: 'Connecting to Hugging Face...'));

      debugPrint('ModelDownloaderService: Starting GET request to $_modelUrl');
      
      await _dio.download(
        _modelUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            // More frequent progress updates for better UX, but still throttled by MB
            if (received % (512 * 1024) == 0 || received == total) {
              controller.add(DownloadProgress(
                progress: progress,
                status: 'Downloading: ${(progress * 100).toStringAsFixed(1)}% (${(received / (1024 * 1024)).toStringAsFixed(1)} / ${(total / (1024 * 1024)).toStringAsFixed(1)} MB)',
              ));
            }
          } else {
            // If total is unknown
            if (received % (1024 * 1024) == 0) {
              controller.add(DownloadProgress(
                progress: 0.0,
                status: 'Downloading: ${(received / (1024 * 1024)).toStringAsFixed(1)} MB (Total unknown)',
              ));
            }
          }
        },
        cancelToken: _cancelToken,
        deleteOnError: true,
      );

      debugPrint('ModelDownloaderService: Download call finished.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelKey, true);

      controller.add(DownloadProgress(progress: 1.0, status: 'Download complete!', isCompleted: true));
    } on DioException catch (e) {
      debugPrint('ModelDownloaderService: DioError: ${e.type} - ${e.message}');
      if (e.response != null) {
        debugPrint('ModelDownloaderService: Response data: ${e.response?.data}');
        debugPrint('ModelDownloaderService: Response status: ${e.response?.statusCode}');
      }
      
      if (CancelToken.isCancel(e)) {
        controller.add(DownloadProgress(progress: 0.0, status: 'Download canceled'));
      } else {
        String errorMsg = 'Network Error';
        if (e.type == DioExceptionType.connectionTimeout) errorMsg = 'Connection Timeout';
        if (e.type == DioExceptionType.receiveTimeout) errorMsg = 'Download Timeout';
        controller.add(DownloadProgress(progress: 0.0, status: 'Download failed', error: '$errorMsg: ${e.message}'));
      }
    } catch (e) {
      debugPrint('ModelDownloaderService: Unexpected error: $e');
      controller.add(DownloadProgress(progress: 0.0, status: 'Download failed', error: e.toString()));
    } finally {
      controller.close();
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
  }
}

import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'model_downloader_progress.dart';

class ModelDownloaderService {
  static const String _modelKey = 'kindle_ai_model_downloaded';
  static const String _modelUrl = 'https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf';
  static const String _modelFileName = 'qwen2.5-coder-1.5b.gguf';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(minutes: 20),
    headers: {
      'User-Agent': 'Kindle/1.0 (Flutter; On-Device AI)',
      'Accept': '*/*',
    },
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
      final length = await file.length();
      debugPrint('ModelDownloaderService: Model file size: ${(length / (1024 * 1024)).toStringAsFixed(1)} MB');
      return length > 100 * 1024 * 1024;
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

      if (await file.exists()) {
        await file.delete();
      }

      _cancelToken = CancelToken();
      controller.add(DownloadProgress(progress: 0.0, status: 'Connecting...'));

      final response = await _dio.get<ResponseBody>(
        _modelUrl,
        options: Options(responseType: ResponseType.stream),
        cancelToken: _cancelToken,
      );

      final totalBytes = int.tryParse(response.headers.value('content-length') ?? '-1') ?? -1;
      int receivedBytes = 0;
      
      final sink = file.openWrite();
      
      await response.data!.stream.listen(
        (chunk) {
          receivedBytes += chunk.length;
          sink.add(chunk);
          
          if (receivedBytes % (1024 * 1024) == 0 || receivedBytes == totalBytes) {
            final progress = totalBytes != -1 ? receivedBytes / totalBytes : 0.0;
            controller.add(DownloadProgress(
              progress: progress,
              status: 'Downloading: ${(progress * 100).toStringAsFixed(1)}% (${(receivedBytes / (1024 * 1024)).toStringAsFixed(1)} / ${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB)',
            ));
          }
        },
        onDone: () async {
          await sink.close();
        },
        onError: (e) {
          sink.close();
          throw e;
        },
        cancelOnError: true,
      ).asFuture();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelKey, true);

      controller.add(DownloadProgress(progress: 1.0, status: 'Download complete!', isCompleted: true));
    } catch (e) {
      controller.add(DownloadProgress(progress: 0.0, status: 'Download failed', error: e.toString()));
    } finally {
      controller.close();
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
  }
}

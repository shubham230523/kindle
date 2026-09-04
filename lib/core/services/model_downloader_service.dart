import 'dart:async';
import 'model_downloader_service_web.dart' if (dart.library.io) 'model_downloader_service_native.dart';

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

abstract class ModelDownloaderService {
  ModelDownloaderService._();
  factory ModelDownloaderService() => ModelDownloaderServiceImpl();
  
  Future<bool> isModelDownloaded();
  Future<String> getModelPath();
  Stream<DownloadProgress> downloadModel();
  void cancelDownload();
}

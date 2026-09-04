import 'dart:async';
import 'model_downloader_progress.dart';

class ModelDownloaderService {
  Future<bool> isModelDownloaded() async => true;

  Future<String> getModelPath() async => '';

  Stream<DownloadProgress> downloadModel() {
    return Stream.value(DownloadProgress(progress: 1.0, status: 'Ready', isCompleted: true));
  }

  void cancelDownload() {}
}

import 'dart:async';
import 'model_downloader_service.dart';

class ModelDownloaderServiceImpl extends ModelDownloaderService {
  @override
  Future<bool> isModelDownloaded() async => true;

  @override
  Future<String> getModelPath() async => '';

  @override
  Stream<DownloadProgress> downloadModel() {
    return Stream.value(DownloadProgress(progress: 1.0, status: 'Ready', isCompleted: true));
  }

  @override
  void cancelDownload() {}
}

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

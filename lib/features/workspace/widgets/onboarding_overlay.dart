import 'package:flutter/material.dart';
import '../../../core/services/model_downloader_service.dart';

class OnboardingOverlay extends StatelessWidget {
  final Stream<DownloadProgress> progressStream;
  final VoidCallback onDismiss;

  const OnboardingOverlay({
    super.key,
    required this.progressStream,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: StreamBuilder<DownloadProgress>(
            stream: progressStream,
            builder: (context, snapshot) {
              final progress = snapshot.data;
              final isError = progress?.error != null;
              final isCompleted = progress?.isCompleted ?? false;

              if (isCompleted) {
                Future.microtask(() => onDismiss());
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.blue, size: 64),
                  const SizedBox(height: 24),
                  const Text(
                    'Preparing AI Engine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isError 
                      ? 'Error: ${progress?.error}'
                      : progress?.status ?? 'Initializing...',
                    style: TextStyle(
                      color: isError ? Colors.red : Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!isError)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress?.progress ?? 0,
                        minHeight: 10,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  const SizedBox(height: 48),
                  if (isError)
                    ElevatedButton(
                      onPressed: onDismiss,
                      child: const Text('Cancel & Close'),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

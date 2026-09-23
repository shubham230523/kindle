import 'dart:async';
import '../../features/project/models/build.dart';
import '../../features/project/models/build_log.dart';

class BuildRunnerService {
  void runBuild({
    required ProjectBuild build,
    required String projectPath,
    required void Function(ProjectBuild) onUpdate,
  }) {
    // Web environment: process execution is not directly supported locally.
    final updatedBuild = build.copyWith(
      status: BuildStatus.failed,
      completedAt: DateTime.now(),
      errorMessage: 'Local command execution is not supported on Web target.',
      logs: [
        ...build.logs,
        BuildLogEntry(
          timestamp: DateTime.now(),
          message: '[ERROR] Local command execution is unsupported on Web target.',
          level: BuildLogLevel.error,
        ),
      ],
    );
    onUpdate(updatedBuild);
  }
}

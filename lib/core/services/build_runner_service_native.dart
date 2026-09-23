import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../features/project/models/build.dart';
import '../../features/project/models/build_log.dart';
import '../../features/project/models/build_analysis.dart';
import '../utils/dev_logger.dart';

class BuildRunnerService {
  void runBuild({
    required ProjectBuild build,
    required String projectPath,
    required void Function(ProjectBuild) onUpdate,
  }) async {
    final platformLower = build.platform.toLowerCase();
    
    String executable = 'flutter';
    List<String> args = [];
    String artifactRelativePath = '';

    if (platformLower.contains('android')) {
      args = ['build', 'apk', '--debug'];
      artifactRelativePath = 'build/app/outputs/flutter-apk/app-debug.apk';
    } else if (platformLower.contains('ios')) {
      args = ['build', 'ios', '--no-codesign'];
      artifactRelativePath = 'build/ios/iphoneos/Runner.app';
    } else if (platformLower.contains('web')) {
      args = ['build', 'web'];
      artifactRelativePath = 'build/web/index.html';
    } else if (platformLower.contains('windows')) {
      args = ['build', 'windows', '--debug'];
      artifactRelativePath = 'build/windows/x64/runner/Debug/kindle.exe';
    } else if (platformLower.contains('linux')) {
      args = ['build', 'linux'];
      artifactRelativePath = 'build/linux/x64/debug/bundle/kindle';
    } else {
      args = ['build', 'apk', '--debug'];
      artifactRelativePath = 'build/app/outputs/flutter-apk/app-debug.apk';
    }

    final logs = List<BuildLogEntry>.from(build.logs);
    logs.add(
      BuildLogEntry(
        timestamp: DateTime.now(),
        message: 'Running command: $executable ${args.join(' ')}',
        level: BuildLogLevel.info,
      ),
    );

    ProjectBuild currentBuild = build.copyWith(
      status: BuildStatus.running,
      progress: 0.1,
      logs: logs,
    );
    onUpdate(currentBuild);

    try {
      final workDir = Directory(projectPath).existsSync()
          ? projectPath
          : Directory.current.path;

      final process = await Process.start(
        executable,
        args,
        workingDirectory: workDir,
        runInShell: true,
      );

      double estimatedProgress = 0.15;

      void addLog(String line, BuildLogLevel defaultLevel) {
        if (line.trim().isEmpty) return;

        BuildLogLevel level = defaultLevel;
        final lower = line.toLowerCase();
        if (lower.contains('error') || lower.contains('failed') || lower.contains('exception') || lower.contains('fatal')) {
          level = BuildLogLevel.error;
        } else if (lower.contains('warning') || lower.contains('deprecated')) {
          level = BuildLogLevel.warning;
        } else if (lower.contains('debug')) {
          level = BuildLogLevel.debug;
        }

        logs.add(
          BuildLogEntry(
            timestamp: DateTime.now(),
            message: line,
            level: level,
          ),
        );

        if (estimatedProgress < 0.90) {
          estimatedProgress += 0.02;
        }

        currentBuild = currentBuild.copyWith(
          logs: List.from(logs),
          progress: estimatedProgress,
        );
        onUpdate(currentBuild);
      }

      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        addLog(line, BuildLogLevel.info);
      });

      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        addLog(line, BuildLogLevel.warning);
      });

      final exitCode = await process.exitCode;
      final completedAt = DateTime.now();

      if (exitCode == 0) {
        logs.add(
          BuildLogEntry(
            timestamp: completedAt,
            message: 'Build succeeded with exit code 0.',
            level: BuildLogLevel.info,
          ),
        );

        BuildArtifact? artifact;
        final artifactFile = File('$workDir/$artifactRelativePath');
        if (artifactFile.existsSync()) {
          final bytes = artifactFile.lengthSync();
          final sizeMb = (bytes / (1024 * 1024)).toStringAsFixed(1);
          final fileName = artifactFile.uri.pathSegments.last;
          artifact = BuildArtifact(
            name: fileName,
            size: '$sizeMb MB',
            type: build.platform.toUpperCase(),
            downloadUrl: artifactFile.path,
          );
        } else {
          artifact = BuildArtifact(
            name: '${build.platform.toLowerCase()}-build',
            size: 'Completed',
            type: build.platform.toUpperCase(),
            downloadUrl: artifactRelativePath,
          );
        }

        currentBuild = currentBuild.copyWith(
          status: BuildStatus.successful,
          progress: 1.0,
          completedAt: completedAt,
          artifact: artifact,
          logs: List.from(logs),
        );
      } else {
        logs.add(
          BuildLogEntry(
            timestamp: completedAt,
            message: '[ERROR] Build failed with exit code $exitCode.',
            level: BuildLogLevel.error,
          ),
        );

        final errorLogEntries = logs.where((l) => l.level == BuildLogLevel.error).toList();
        final lastErrorMsg = errorLogEntries.isNotEmpty
            ? errorLogEntries.last.message
            : 'Build process exited with code $exitCode.';

        final failureAnalysis = BuildFailureAnalysis(
          errorSummary: lastErrorMsg,
          likelyCause: 'Build error occurred during $executable ${args.join(' ')}.',
          suggestedSolution: 'Review the detailed build logs above to identify compilation or toolchain issues.',
        );

        currentBuild = currentBuild.copyWith(
          status: BuildStatus.failed,
          progress: 1.0,
          completedAt: completedAt,
          errorMessage: lastErrorMsg,
          failureAnalysis: failureAnalysis,
          logs: List.from(logs),
        );
      }

      onUpdate(currentBuild);
    } catch (e, stack) {
      DevLogger.log('BuildRunnerService error: $e\n$stack');
      final completedAt = DateTime.now();
      logs.add(
        BuildLogEntry(
          timestamp: completedAt,
          message: '[ERROR] Failed to launch build process: $e',
          level: BuildLogLevel.error,
        ),
      );

      currentBuild = currentBuild.copyWith(
        status: BuildStatus.failed,
        progress: 1.0,
        completedAt: completedAt,
        errorMessage: 'Failed to launch build process: $e',
        failureAnalysis: BuildFailureAnalysis(
          errorSummary: 'Process execution error: $e',
          likelyCause: 'Unable to start $executable command.',
          suggestedSolution: 'Ensure Flutter SDK and build tools are installed and available in PATH.',
        ),
        logs: List.from(logs),
      );

      onUpdate(currentBuild);
    }
  }
}

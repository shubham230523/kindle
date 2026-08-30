import 'build_log_screen.dart';
import 'widgets/build_analysis_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../project/models/project.dart';
import '../../project/models/build.dart';
import '../../project/models/build_analysis.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class BuildDashboardScreen extends StatefulWidget {
  final Project project;

  const BuildDashboardScreen({super.key, required this.project});

  @override
  State<BuildDashboardScreen> createState() => _BuildDashboardScreenState();
}

class _BuildDashboardScreenState extends State<BuildDashboardScreen> {
  late List<ProjectBuild> _builds;

  @override
  void initState() {
    super.initState();
    _builds = _generateMockBuilds();
  }

  List<ProjectBuild> _generateMockBuilds() {
    final now = DateTime.now();
    return [
      ProjectBuild(
        id: 'b1',
        platform: 'Android',
        status: BuildStatus.successful,
        progress: 1.0,
        startedAt: now.subtract(const Duration(hours: 5)),
        completedAt: now.subtract(const Duration(hours: 4, minutes: 50)),
        artifact: const BuildArtifact(name: 'app-release.apk', size: '24 MB', type: 'APK', downloadUrl: '#'),
      ),
      ProjectBuild(
        id: 'b2',
        platform: 'iOS',
        status: BuildStatus.failed,
        progress: 0.65,
        startedAt: now.subtract(const Duration(hours: 3)),
        completedAt: now.subtract(const Duration(hours: 2, minutes: 55)),
        errorMessage: 'Code signing error: Certificate expired.',
        failureAnalysis: const BuildFailureAnalysis(
          errorSummary: 'Automatic code signing failed for iOS.',
          likelyCause: 'The development certificate used for this build has expired or is no longer valid in the keychain.',
          affectedFiles: ['ios/Runner.xcodeproj', 'ios/Podfile'],
          suggestedSolution: 'Renew the development certificate in the Apple Developer portal and re-sync the project configuration.',
          confidence: 0.98,
        ),
      ),
      ProjectBuild(
        id: 'b3',
        platform: 'Web',
        status: BuildStatus.running,
        progress: 0.45,
        startedAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activeBuild = _builds.firstWhere((b) => b.status == BuildStatus.running, orElse: () => _builds.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Builds & Deployments'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuildLogScreen(build: activeBuild),
                        ),
                      );
                    },
                    child: _ActiveBuildCard(projectBuild: activeBuild),
                  ),
                  if (activeBuild.status == BuildStatus.failed && activeBuild.failureAnalysis != null) ...[
                    const SizedBox(height: AppConstants.spacingLg),
                    BuildAnalysisWidget(
                      analysis: activeBuild.failureAnalysis!,
                      onRetry: () {},
                      onFix: () {},
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacingLg),
                  const SectionTitle(title: 'Build History'),
                  ..._builds.map((b) => _BuildHistoryItem(projectBuild: b)),
                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveBuildCard extends StatelessWidget {
  final ProjectBuild projectBuild;
  const _ActiveBuildCard({required this.projectBuild});

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Build: ${projectBuild.platform}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ID: ${projectBuild.id}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              _BuildStatusBadge(status: projectBuild.status),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),
          if (projectBuild.status == BuildStatus.running) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress: ${(projectBuild.progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Started: ${DateFormat('HH:mm').format(projectBuild.startedAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: projectBuild.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ] else if (projectBuild.status == BuildStatus.successful && projectBuild.artifact != null) ...[
            _ArtifactSection(artifact: projectBuild.artifact!),
          ] else if (projectBuild.status == BuildStatus.failed) ...[
            _ErrorSection(message: projectBuild.errorMessage ?? 'Unknown build error.'),
          ],
          const SizedBox(height: AppConstants.spacingLg),
          SizedBox(
            width: double.infinity,
            child: KindleButton.secondary(
              text: projectBuild.status == BuildStatus.running ? 'Cancel Build' : 'New Build',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtifactSection extends StatelessWidget {
  final BuildArtifact artifact;
  const _ArtifactSection({required this.artifact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(artifact.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${artifact.type} • ${artifact.size}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.download, size: 20), onPressed: () {}),
        ],
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  const _ErrorSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _BuildHistoryItem extends StatelessWidget {
  final ProjectBuild projectBuild;
  const _BuildHistoryItem({required this.projectBuild});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, HH:mm').format(projectBuild.startedAt);
    final durationStr = projectBuild.duration != null ? '${projectBuild.duration!.inMinutes}m ${projectBuild.duration!.inSeconds % 60}s' : '--';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          dense: true,
          leading: _BuildStatusIcon(status: projectBuild.status),
          title: Text('${projectBuild.platform} Build', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$timeStr • $durationStr'),
          trailing: const Icon(Icons.chevron_right, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuildLogScreen(build: projectBuild),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BuildStatusIcon extends StatelessWidget {
  final BuildStatus status;
  const _BuildStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (status) {
      case BuildStatus.successful:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case BuildStatus.failed:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case BuildStatus.running:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case BuildStatus.queued:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
    }
    return Icon(icon, color: color, size: 20);
  }
}

class _BuildStatusBadge extends StatelessWidget {
  final BuildStatus status;
  const _BuildStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case BuildStatus.successful:
        color = Colors.green;
        break;
      case BuildStatus.failed:
        color = Colors.red;
        break;
      case BuildStatus.running:
        color = Colors.blue;
        break;
      case BuildStatus.queued:
        color = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

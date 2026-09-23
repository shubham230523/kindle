import 'build_log_screen.dart';
import 'widgets/build_analysis_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workspace_viewmodel.dart';
import '../../project/models/project.dart';
import '../../project/models/build.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../shared/widgets/empty_state.dart';
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
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkspaceViewModel>();
    final builds = viewModel.project.builds;

    if (builds.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Builds & Deployments'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const KindleEmptyState(
                title: 'No Builds Yet',
                message: 'Build artifacts and deployment status will appear here when builds run.',
                icon: Icons.build_circle_outlined,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              KindleButton(
                text: 'Trigger Android Build',
                icon: Icons.play_arrow,
                onPressed: () {
                  context.read<WorkspaceViewModel>().runBuild('Android');
                },
              ),
            ],
          ),
        ),
      );
    }

    final activeBuild = builds.firstWhere((b) => b.status == BuildStatus.running, orElse: () => builds.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Builds & Deployments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<WorkspaceViewModel>().runBuild('Android');
            },
          ),
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
                  ...builds.map((b) => _BuildHistoryItem(projectBuild: b)),
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
              text: 'New Build',
              onPressed: () {
                context.read<WorkspaceViewModel>().runBuild('iOS');
              },
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

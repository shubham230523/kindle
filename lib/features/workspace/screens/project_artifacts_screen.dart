import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../project/models/project.dart';
import '../../project/models/artifact.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class ProjectArtifactsScreen extends StatelessWidget {
  final Project project;

  const ProjectArtifactsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final artifacts = project.artifacts.isNotEmpty ? project.artifacts : _generateMockArtifacts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Artifacts'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: artifacts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionTitle(
                  title: 'Generated Artifacts',
                  subtitle: 'Central repository for all project deliverables.',
                );
              }
              return _ArtifactCard(artifact: artifacts[index - 1]);
            },
          ),
        ),
      ),
    );
  }

  List<ProjectArtifact> _generateMockArtifacts() {
    final now = DateTime.now();
    return [
      ProjectArtifact(
        id: 'art1',
        name: 'Source Code (Stable)',
        type: ArtifactType.sourceCode,
        generatedAt: now.subtract(const Duration(minutes: 45)),
        status: ArtifactStatus.current,
        size: '1.2 MB',
      ),
      ProjectArtifact(
        id: 'art2',
        name: 'Technical Architecture Document',
        type: ArtifactType.architecture,
        generatedAt: now.subtract(const Duration(hours: 2)),
        status: ArtifactStatus.current,
        size: '450 KB',
      ),
      ProjectArtifact(
        id: 'art3',
        name: 'Requirements Specification',
        type: ArtifactType.documentation,
        generatedAt: now.subtract(const Duration(hours: 5)),
        status: ArtifactStatus.outdated,
        size: '280 KB',
      ),
      ProjectArtifact(
        id: 'art4',
        name: 'Development Roadmap v1',
        type: ArtifactType.plan,
        generatedAt: now.subtract(const Duration(days: 1)),
        status: ArtifactStatus.current,
        size: '150 KB',
      ),
      ProjectArtifact(
        id: 'art5',
        name: 'Widget Test Report',
        type: ArtifactType.testReport,
        generatedAt: now.subtract(const Duration(minutes: 10)),
        status: ArtifactStatus.current,
        size: '1.5 MB',
      ),
      ProjectArtifact(
        id: 'art6',
        name: 'Android Preview Build',
        type: ArtifactType.build,
        generatedAt: now.subtract(const Duration(hours: 1)),
        status: ArtifactStatus.failed,
        size: '0 KB',
      ),
    ];
  }
}

class _ArtifactCard extends StatelessWidget {
  final ProjectArtifact artifact;
  const _ArtifactCard({required this.artifact});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, HH:mm').format(artifact.generatedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: _ArtifactTypeIcon(type: artifact.type),
          title: Text(artifact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$dateStr • ${artifact.size}'),
          trailing: _ArtifactStatusBadge(status: artifact.status),
          onTap: () {
            // Placeholder for download action
          },
        ),
      ),
    );
  }
}

class _ArtifactTypeIcon extends StatelessWidget {
  final ArtifactType type;
  const _ArtifactTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type) {
      case ArtifactType.sourceCode:
        icon = Icons.code;
        color = Colors.blue;
        break;
      case ArtifactType.documentation:
        icon = Icons.description;
        color = Colors.orange;
        break;
      case ArtifactType.architecture:
        icon = Icons.account_tree;
        color = Colors.purple;
        break;
      case ArtifactType.plan:
        icon = Icons.map;
        color = Colors.teal;
        break;
      case ArtifactType.build:
        icon = Icons.build_circle;
        color = Colors.indigo;
        break;
      case ArtifactType.testReport:
        icon = Icons.fact_check;
        color = Colors.green;
        break;
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _ArtifactStatusBadge extends StatelessWidget {
  final ArtifactStatus status;
  const _ArtifactStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case ArtifactStatus.current:
        color = Colors.green;
        label = 'CURRENT';
        break;
      case ArtifactStatus.outdated:
        color = Colors.amber;
        label = 'OUTDATED';
        break;
      case ArtifactStatus.processing:
        color = Colors.blue;
        label = 'PROCESSING';
        break;
      case ArtifactStatus.failed:
        color = Colors.red;
        label = 'FAILED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

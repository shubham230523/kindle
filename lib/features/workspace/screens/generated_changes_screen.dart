import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../project/models/project.dart';
import '../../project/models/file_change.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class GeneratedChangesScreen extends StatelessWidget {
  final Project project;

  const GeneratedChangesScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Generate mock data if empty for demonstration
    final List<FileChange> displayChanges = project.fileChanges.isNotEmpty 
        ? project.fileChanges 
        : _generateMockChanges();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Changes'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: displayChanges.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionTitle(
                  title: 'File Change History',
                  subtitle: 'Audit trail of all autonomous modifications.',
                );
              }
              final change = displayChanges[index - 1];
              return _FileChangeCard(change: change);
            },
          ),
        ),
      ),
    );
  }

  List<FileChange> _generateMockChanges() {
    final now = DateTime.now();
    return [
      FileChange(
        id: 'c1',
        filePath: 'lib/core/theme/app_theme.dart',
        type: FileChangeType.created,
        agentName: 'Architecture Agent',
        taskTitle: 'Initialize Theme System',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      FileChange(
        id: 'c2',
        filePath: 'lib/main.dart',
        type: FileChangeType.modified,
        agentName: 'Coding Agent',
        taskTitle: 'Setup Entry Point',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      FileChange(
        id: 'c3',
        filePath: 'test/old_test.dart',
        type: FileChangeType.deleted,
        agentName: 'Build Agent',
        taskTitle: 'Cleanup Project',
        timestamp: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}

class _FileChangeCard extends StatelessWidget {
  final FileChange change;

  const _FileChangeCard({required this.change});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, HH:mm').format(change.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ChangeTypeIcon(type: change.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        change.filePath,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'By ${change.agentName} • $timeStr',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _ChangeTypeBadge(type: change.type),
              ],
            ),
            const Divider(height: AppConstants.spacingLg),
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Task: ${change.taskTitle}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeTypeIcon extends StatelessWidget {
  final FileChangeType type;
  const _ChangeTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (type) {
      case FileChangeType.created:
        icon = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case FileChangeType.modified:
        icon = Icons.edit_note;
        color = Colors.blue;
        break;
      case FileChangeType.deleted:
        icon = Icons.remove_circle_outline;
        color = Colors.red;
        break;
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _ChangeTypeBadge extends StatelessWidget {
  final FileChangeType type;
  const _ChangeTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case FileChangeType.created:
        color = Colors.green;
        break;
      case FileChangeType.modified:
        color = Colors.blue;
        break;
      case FileChangeType.deleted:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}

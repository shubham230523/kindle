import 'package:flutter/material.dart';
import '../models/task.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          _StatusBadge(status: task.status),
          const SizedBox(width: AppConstants.spacingMd),
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
                  _HeaderSection(task: task),
                  const SizedBox(height: AppConstants.spacingLg),
                  const SectionTitle(title: 'Description'),
                  KindleCard(
                    child: Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  if (task.expectedOutput != null) ...[
                    const SectionTitle(title: 'Expected Output'),
                    KindleCard(
                      child: Text(
                        task.expectedOutput!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  if (task.dependencies.isNotEmpty) ...[
                    const SectionTitle(title: 'Dependencies'),
                    KindleCard(
                      child: Wrap(
                        spacing: AppConstants.spacingSm,
                        children: task.dependencies
                            .map((d) => Chip(
                                  label: Text(d, style: const TextStyle(fontSize: 12)),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  if (task.filesToChange.isNotEmpty) ...[
                    const SectionTitle(title: 'Files to Change'),
                    KindleCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: task.filesToChange
                            .map((f) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description_outlined, size: 16, color: AppColors.primary),
                                      const SizedBox(width: AppConstants.spacingSm),
                                      Text(f, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  if (task.acceptanceCriteria.isNotEmpty) ...[
                    const SectionTitle(title: 'Acceptance Criteria'),
                    KindleCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: task.acceptanceCriteria
                            .map((c) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_box_outlined, size: 18, color: Colors.green),
                                      const SizedBox(width: AppConstants.spacingSm),
                                      Expanded(child: Text(c)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                  const _ExecutionPlaceholder(),
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

class _HeaderSection extends StatelessWidget {
  final Task task;

  const _HeaderSection({required this.task});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ComplexityBadge(complexity: task.complexity),
            const SizedBox(width: AppConstants.spacingSm),
            Text(
              'Phase ID: ${task.phaseId}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TaskStatus.done:
        color = Colors.green;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        break;
      case TaskStatus.blocked:
        color = Colors.red;
        break;
      case TaskStatus.todo:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ComplexityBadge extends StatelessWidget {
  final TaskComplexity complexity;

  const _ComplexityBadge({required this.complexity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (complexity) {
      case TaskComplexity.low:
        color = Colors.green;
        break;
      case TaskComplexity.medium:
        color = Colors.orange;
        break;
      case TaskComplexity.high:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${complexity.name.toUpperCase()} COMPLEXITY',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ExecutionPlaceholder extends StatelessWidget {
  const _ExecutionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        children: [
          const Icon(Icons.bolt, color: Colors.amber, size: 48),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'AI Agent Execution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'This task is ready for automated execution. Once initialized, the Kindle AI agent will generate the code, run tests, and verify acceptance criteria.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Future execution logic
              },
              child: const Text('Initialize Agent (Coming Soon)'),
            ),
          ),
        ],
      ),
    );
  }
}

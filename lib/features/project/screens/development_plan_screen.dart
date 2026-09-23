import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/phase.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class DevelopmentPlanScreen extends StatelessWidget {
  final Project project;

  const DevelopmentPlanScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final plan = project.developmentPlan;
    final phases = plan?.phases ?? [];

    if (phases.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Development Roadmap'),
        ),
        body: const KindleEmptyState(
          title: 'No Development Plan',
          message: 'Development plan and tasks will appear here once generated.',
          icon: Icons.map_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Development Roadmap'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: phases.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionTitle(
                  title: 'Project Execution Plan',
                  subtitle: 'Step-by-step roadmap to build your sparked idea.',
                );
              }
              final phase = phases[index - 1];
              return _PhaseExpansionTile(phase: phase);
            },
          ),
        ),
      ),
    );
  }
}

class _PhaseExpansionTile extends StatelessWidget {
  final Phase phase;

  const _PhaseExpansionTile({required this.phase});

  @override
  Widget build(BuildContext context) {
    final completedTasks = phase.tasks.where((t) => t.status == TaskStatus.done).length;
    final progress = phase.tasks.isEmpty ? 0.0 : completedTasks / phase.tasks.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: _CircularProgressIndicator(progress: progress),
          title: Text(
            phase.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            phase.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          children: phase.tasks.map((task) => _TaskTile(task: task)).toList(),
        ),
      ),
    );
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  final double progress;

  const _CircularProgressIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          backgroundColor: Colors.grey.shade100,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        if (progress == 1.0)
          const Icon(Icons.check, size: 16, color: AppColors.primary)
        else
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;

    return ListTile(
      dense: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(task: task),
          ),
        );
      },
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isDone ? Colors.green : Colors.grey,
        size: 20,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isDone ? Colors.grey : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(task.description),
      trailing: _ComplexityBadge(complexity: task.complexity),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        complexity.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}

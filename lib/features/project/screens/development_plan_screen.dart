import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/development_plan.dart';
import '../models/phase.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class DevelopmentPlanScreen extends StatefulWidget {
  final Project project;

  const DevelopmentPlanScreen({super.key, required this.project});

  @override
  State<DevelopmentPlanScreen> createState() => _DevelopmentPlanScreenState();
}

class _DevelopmentPlanScreenState extends State<DevelopmentPlanScreen> {
  late DevelopmentPlan _plan;

  @override
  void initState() {
    super.initState();
    _plan = _generateMockPlan();
  }

  DevelopmentPlan _generateMockPlan() {
    return DevelopmentPlan(
      id: 'plan_1',
      projectId: widget.project.id,
      createdAt: DateTime.now(),
      phases: [
        Phase(
          id: 'p1',
          title: 'Project Setup',
          description: 'Initialize repository and configure environment.',
          tasks: [
            const Task(
              id: 't1_1',
              title: 'Initialize Git Repository',
              description: 'Setup version control and base branching strategy.',
              expectedOutput: 'A clean repository with initial commits.',
              filesToChange: ['.gitignore', 'README.md'],
              acceptanceCriteria: ['Repo initialized', 'Remote origin set'],
              phaseId: 'p1',
              status: TaskStatus.done,
            ),
            const Task(
              id: 't1_2',
              title: 'Setup CI/CD Pipeline',
              description: 'Configure automated builds and deployment scripts.',
              expectedOutput: 'Working GitHub Action or GitLab CI file.',
              filesToChange: ['.github/workflows/main.yml'],
              acceptanceCriteria: ['Build passes on push', 'Tests run automatically'],
              phaseId: 'p1',
              complexity: TaskComplexity.high,
            ),
          ],
        ),
        Phase(
          id: 'p2',
          title: 'Foundation',
          description: 'Core architecture and shared components.',
          tasks: [
            const Task(
              id: 't2_1',
              title: 'Implement Theme System',
              description: 'Centralize colors, spacing, and typography.',
              expectedOutput: 'AppTheme class and reusable style tokens.',
              filesToChange: ['lib/core/theme/app_theme.dart', 'lib/core/theme/app_colors.dart'],
              acceptanceCriteria: ['Dark mode support', 'Responsive spacing tokens'],
              phaseId: 'p2',
              status: TaskStatus.done,
            ),
            const Task(
              id: 't2_2',
              title: 'Setup Dependency Injection',
              description: 'Configure service locator for decoupled services.',
              expectedOutput: 'Injection container initialized in main.',
              phaseId: 'p2',
            ),
          ],
        ),
        const Phase(
          id: 'p3',
          title: 'Authentication',
          description: 'User registration and login flows.',
          tasks: [
            Task(id: 't3_1', title: 'Create Auth Repository', description: 'Integration with Backend.', phaseId: 'p3'),
            Task(id: 't3_2', title: 'UI: Login Screen', description: 'Responsive login form.', phaseId: 'p3'),
          ],
        ),
        Phase(
          id: 'p4',
          title: 'Core Features',
          description: 'Building the primary value proposition.',
          tasks: widget.project.features.map((f) => Task(
            id: 't4_${f.id}',
            title: 'Implement ${f.name}',
            description: f.description,
            expectedOutput: 'Fully functional ${f.name} module.',
            acceptanceCriteria: ['Unit tests pass', 'UI matches design'],
            phaseId: 'p4',
            complexity: TaskComplexity.high,
          )).toList(),
        ),
        const Phase(
          id: 'p5',
          title: 'Testing & QA',
          description: 'Ensuring application stability.',
          tasks: [
            Task(id: 't5_1', title: 'Unit Testing', description: 'Write tests for business logic.', phaseId: 'p5'),
            Task(id: 't5_2', title: 'Integration Testing', description: 'End-to-end flow validation.', phaseId: 'p5'),
          ],
        ),
        const Phase(
          id: 'p6',
          title: 'Release',
          description: 'Preparation for app store submission.',
          tasks: [
            Task(id: 't6_1', title: 'App Store Metadata', description: 'Gather descriptions and screenshots.', phaseId: 'p6'),
            Task(id: 't6_2', title: 'Production Build', description: 'Final release build generation.', phaseId: 'p6'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Development Roadmap'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: _plan.phases.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionTitle(
                  title: 'Project Execution Plan',
                  subtitle: 'Step-by-step roadmap to build your sparked idea.',
                );
              }
              final phase = _plan.phases[index - 1];
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

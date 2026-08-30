import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/requirement.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class RequirementsListScreen extends StatelessWidget {
  final Project project;

  const RequirementsListScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requirements'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: project.requirements.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SectionTitle(
                  title: 'Project Requirements',
                  subtitle: 'Formalized user needs and priority tracking.',
                );
              }
              final requirement = project.requirements[index - 1];
              return _RequirementCard(requirement: requirement);
            },
          ),
        ),
      ),
    );
  }
}

class _RequirementCard extends StatelessWidget {
  final Requirement requirement;

  const _RequirementCard({required this.requirement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: KindleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    requirement.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                _PriorityBadge(priority: requirement.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              requirement.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final RequirementPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case RequirementPriority.low:
        color = Colors.blue;
        break;
      case RequirementPriority.medium:
        color = Colors.orange;
        break;
      case RequirementPriority.high:
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
        priority.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/architecture.dart';
import '../models/module.dart';
import '../models/technology_dependency.dart';
import 'development_plan_screen.dart';
import 'widgets/architecture_diagram.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class ArchitectureOverviewScreen extends StatelessWidget {
  final Project project;

  const ArchitectureOverviewScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final architecture = project.architecture;

    if (architecture == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Architecture Blueprint'),
        ),
        body: const KindleEmptyState(
          title: 'No Architecture Defined',
          message: 'Architecture blueprint and system layers will appear here when defined.',
          icon: Icons.account_tree_outlined,
        ),
      );
    }

    final bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Architecture Blueprint'),
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
                  _PatternCard(pattern: architecture.pattern),
                  const SizedBox(height: AppConstants.spacingLg),
                  const SectionTitle(title: 'Visual Blueprint'),
                  const ArchitectureDiagram(),
                  if (architecture.layers.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingLg),
                    const SectionTitle(title: 'Structural Layers'),
                    _LayersList(layers: architecture.layers),
                  ],
                  if (architecture.modules.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingLg),
                    const SectionTitle(title: 'Module Breakdown'),
                    _ModulesGrid(modules: architecture.modules, isDesktop: isDesktop),
                  ],
                  if (architecture.technologyDependencies.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spacingLg),
                    const SectionTitle(title: 'Dependency Overview'),
                    _DependenciesCard(dependencies: architecture.technologyDependencies),
                  ],
                  const SizedBox(height: AppConstants.spacingLg),
                  const SectionTitle(title: 'Data Flow Summary'),
                  KindleCard(
                    child: Text(
                      'Unidirectional data flow ensures state consistency. Events originate from the UI, processed by the business logic layer, and results are propagated back through reactive streams.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  KindleButton(
                    text: 'View Development Roadmap',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DevelopmentPlanScreen(project: project),
                        ),
                      );
                    },
                  ),
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

class _PatternCard extends StatelessWidget {
  final ArchitecturePattern pattern;

  const _PatternCard({required this.pattern});

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.account_tree, color: Colors.white),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Architecture Pattern', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  pattern.name.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayersList extends StatelessWidget {
  final List<String> layers;

  const _LayersList({required this.layers});

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      child: Column(
        children: layers.asMap().entries.map((entry) {
          final isLast = entry.key == layers.length - 1;
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                ),
                title: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (!isLast)
                const Icon(Icons.arrow_downward, size: 16, color: Colors.grey),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ModulesGrid extends StatelessWidget {
  final List<Module> modules;
  final bool isDesktop;

  const _ModulesGrid({required this.modules, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spacingMd,
      runSpacing: AppConstants.spacingMd,
      children: modules.map((module) {
        return SizedBox(
          width: isDesktop ? (kMaxContentWidth / 2) - AppConstants.spacingLg : double.infinity,
          child: KindleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(module.responsibility, style: Theme.of(context).textTheme.bodySmall),
                if (module.dependencies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: module.dependencies.map((d) => Chip(
                      label: Text(d, style: const TextStyle(fontSize: 8)),
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DependenciesCard extends StatelessWidget {
  final List<TechnologyDependency> dependencies;

  const _DependenciesCard({required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: dependencies.map((dep) => Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        child: KindleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dep.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      dep.category,
                      style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: AppConstants.spacingXs),
                  Expanded(
                    child: Text(
                      'Purpose: ${dep.purpose}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (dep.whySelected.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Selection Strategy:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  dep.whySelected,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      )).toList(),
    );
  }
}

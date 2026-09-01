import 'package:flutter/material.dart';
import '../models/project.dart';
import 'project_edit_screen.dart';
import 'platform_selection_screen.dart';
import 'technology_selection_screen.dart';
import 'backend_selection_screen.dart';
import '../../workspace/screens/project_workspace_shell.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class ProjectSummaryScreen extends StatefulWidget {
  final Project project;

  const ProjectSummaryScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectSummaryScreen> createState() => _ProjectSummaryScreenState();
}

class _ProjectSummaryScreenState extends State<ProjectSummaryScreen> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  void _handleEdit() async {
    final updatedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectEditScreen(project: _project),
      ),
    );

    if (updatedProject != null) {
      setState(() {
        _project = updatedProject;
      });
    }
  }

  void _handlePlatformSelection() async {
    final updatedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformSelectionScreen(project: _project),
      ),
    );

    if (updatedProject != null) {
      setState(() {
        _project = updatedProject;
      });
    }
  }

  void _handleTechSelection() async {
    final updatedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => TechnologySelectionScreen(project: _project),
      ),
    );

    if (updatedProject != null) {
      setState(() {
        _project = updatedProject;
      });
    }
  }

  void _handleBackendSelection() async {
    final updatedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => BackendSelectionScreen(project: _project),
      ),
    );

    if (updatedProject != null) {
      setState(() {
        _project = updatedProject;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _handleEdit,
            tooltip: 'Edit Project',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: AppConstants.spacingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderSection(project: _project),
                    const SizedBox(height: AppConstants.spacingMd),
                    _OverviewSection(project: _project),
                    if (_project.platforms.isNotEmpty)
                      _PlatformsSection(project: _project),
                    if (_project.selectedTechnology != null)
                      _TechSection(project: _project),
                    if (_project.selectedBackend != null || _project.selectedDatabase != null)
                      _BackendDatabaseSection(project: _project),
                    _FeaturesSection(project: _project),
                    const SizedBox(height: AppConstants.spacingLg),
                    _ActionSection(
                      project: _project,
                      onPlatformSelect: _handlePlatformSelection,
                      onTechSelect: _handleTechSelection,
                      onBackendSelect: _handleBackendSelection,
                      onEdit: _handleEdit,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Project project;

  const _HeaderSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final bool isSparked = project.platforms.isNotEmpty && project.selectedTechnology != null;
    
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (isSparked ? Colors.blue : Colors.green).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Text(
                  isSparked ? 'Project Roadmap' : 'Sparked Draft',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSparked ? Colors.blue.shade700 : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final Project project;

  const _OverviewSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Overview'),
        KindleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBlock(
                context,
                'Description',
                project.description,
                Icons.notes,
              ),
              const Divider(height: AppConstants.spacingLg),
              _buildInfoBlock(
                context,
                'Target Users',
                project.targetUsers ?? 'Not specified',
                Icons.people_outline,
              ),
              const Divider(height: AppConstants.spacingLg),
              _buildInfoBlock(
                context,
                'Problem Statement',
                project.problemStatement ?? 'Not specified',
                Icons.report_problem_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBlock(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppConstants.spacingSm),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

class _PlatformsSection extends StatelessWidget {
  final Project project;

  const _PlatformsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: 'Target Platforms'),
            TextButton(
              onPressed: () {
                // Should navigate to platform selection again if needed
              },
              child: const Text('Change'),
            ),
          ],
        ),
        KindleCard(
          child: Wrap(
            spacing: AppConstants.spacingSm,
            runSpacing: AppConstants.spacingSm,
            children: project.platforms.map((platform) {
              return Chip(
                label: Text(platform[0].toUpperCase() + platform.substring(1)),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                side: BorderSide.none,
                labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TechSection extends StatelessWidget {
  final Project project;

  const _TechSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: 'Spark Stack'),
            TextButton(
              onPressed: () {
                // Navigate back to tech selection
              },
              child: const Text('Change'),
            ),
          ],
        ),
        KindleCard(
          child: Row(
            children: [
              const Icon(Icons.layers_outlined, color: AppColors.primary),
              const SizedBox(width: AppConstants.spacingMd),
              Text(
                project.selectedTechnology ?? 'None selected',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackendDatabaseSection extends StatelessWidget {
  final Project project;

  const _BackendDatabaseSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: 'Infrastructure'),
            TextButton(
              onPressed: () {
                // Navigate back to backend selection
              },
              child: const Text('Change'),
            ),
          ],
        ),
        KindleCard(
          child: Column(
            children: [
              _buildInfraRow(Icons.cloud_outlined, "Backend", project.selectedBackend ?? "None"),
              const Divider(),
              _buildInfraRow(Icons.storage_outlined, "Database", project.selectedDatabase ?? "None"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfraRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppConstants.spacingMd),
          Text("$label: ", style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final Project project;

  const _FeaturesSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Core Features'),
        Wrap(
          spacing: AppConstants.spacingMd,
          runSpacing: AppConstants.spacingMd,
          children: project.features.map((feature) {
            return SizedBox(
              width: ResponsiveLayout.isMobile(context) ? double.infinity : (kMaxContentWidth / 2) - AppConstants.spacingLg,
              child: KindleCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  final Project project;
  final VoidCallback onPlatformSelect;
  final VoidCallback onTechSelect;
  final VoidCallback onBackendSelect;
  final VoidCallback onEdit;

  const _ActionSection({
    required this.project,
    required this.onPlatformSelect,
    required this.onTechSelect,
    required this.onBackendSelect,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlatforms = project.platforms.isNotEmpty;
    final hasTech = project.selectedTechnology != null;
    final hasInfra = project.selectedBackend != null || project.selectedDatabase != null;

    return Column(
      children: [
        if (!hasPlatforms)
          SizedBox(
            width: double.infinity,
            child: KindleButton(
              text: 'Select Target Platforms',
              onPressed: onPlatformSelect,
            ),
          )
        else if (!hasTech)
          SizedBox(
            width: double.infinity,
            child: KindleButton(
              text: 'Choose Spark Stack',
              onPressed: onTechSelect,
            ),
          )
        else if (!hasInfra)
          SizedBox(
            width: double.infinity,
            child: KindleButton(
              text: 'Configure Infrastructure',
              onPressed: onBackendSelect,
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: KindleButton(
              text: 'Create Project Workspace',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectWorkspaceShell(project: project),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: AppConstants.spacingMd),
        SizedBox(
          width: double.infinity,
          child: KindleButton.secondary(
            text: 'Refine Discovery',
            onPressed: onEdit,
          ),
        ),
      ],
    );
  }
}

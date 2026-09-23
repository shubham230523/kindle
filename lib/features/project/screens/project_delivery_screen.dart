import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class ProjectDeliveryScreen extends StatelessWidget {
  final Project project;

  const ProjectDeliveryScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ship & Delivery'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd, vertical: AppConstants.spacingXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SuccessHeader(projectName: project.name),
                  const SizedBox(height: AppConstants.spacingXl),
                  _OverviewCard(project: project),
                  const SizedBox(height: AppConstants.spacingLg),
                  const SectionTitle(title: 'Generated Deliverables'),
                  _ArtifactsList(project: project),
                  const SizedBox(height: AppConstants.spacingXl),
                  _DeliveryActions(),
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

class _SuccessHeader extends StatelessWidget {
  final String projectName;
  const _SuccessHeader({required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.rocket_launch, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        Text(
          'Project Readiness',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '$projectName delivery dashboard.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final Project project;
  const _OverviewCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        children: [
          _buildInfoRow('Technology', project.selectedTechnology ?? 'Not Selected'),
          const Divider(height: 24),
          _buildInfoRow('Platforms', project.platforms.isEmpty ? 'None' : project.platforms.join(', ').toUpperCase()),
          const Divider(height: 24),
          _buildInfoRow('Files Generated', '${project.fileChanges.length} files'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ArtifactsList extends StatelessWidget {
  final Project project;
  const _ArtifactsList({required this.project});

  @override
  Widget build(BuildContext context) {
    if (project.artifacts.isEmpty) {
      return const KindleEmptyState(
        title: 'No Deliverables Ready',
        message: 'Generated packages and build artifacts will appear here upon completion.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return KindleCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: project.artifacts.map((artifact) {
          return ListTile(
            leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
            title: Text(artifact.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: Text(artifact.size, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.download, size: 20),
            onTap: () {},
          );
        }).toList(),
      ),
    );
  }
}

class _DeliveryActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: KindleButton(
            text: 'View Source Code',
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

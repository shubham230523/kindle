import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class ProjectDeliveryScreen extends StatelessWidget {
  final Project project;

  const ProjectDeliveryScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SectionTitle(title: 'Quality & Delivery Metrics'),
                  Row(
                    children: [
                      Expanded(child: _MetricCard(label: 'Build', value: 'STABLE', color: Colors.green, icon: Icons.build_circle)),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(child: _MetricCard(label: 'Tests', value: '100% PASS', color: Colors.green, icon: Icons.fact_check)),
                    ],
                  ),
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
        const Icon(Icons.auto_awesome, size: 80, color: Colors.amber),
        const SizedBox(height: 24),
        Text(
          'Spark Successful!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '$projectName is ready for the world.',
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
          _buildInfoRow('Technology', project.selectedTechnology ?? 'Flutter'),
          const Divider(height: 24),
          _buildInfoRow('Platforms', project.platforms.join(', ').toUpperCase()),
          const Divider(height: 24),
          _buildInfoRow('Files Generated', '124 files'),
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

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ArtifactsList extends StatelessWidget {
  final Project project;
  const _ArtifactsList({required this.project});

  @override
  Widget build(BuildContext context) {
    return KindleCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildArtifactTile(Icons.code, 'Source Code Bundle', '2.4 MB'),
          const Divider(height: 1),
          _buildArtifactTile(Icons.description, 'Project Documentation', '450 KB'),
          const Divider(height: 1),
          _buildArtifactTile(Icons.android, 'Production APK', '18.2 MB'),
        ],
      ),
    );
  }

  Widget _buildArtifactTile(IconData icon, String name, String size) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(size, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.download, size: 20),
      onTap: () {},
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
        const SizedBox(height: AppConstants.spacingMd),
        SizedBox(
          width: double.infinity,
          child: KindleButton.secondary(
            text: 'Return to Dashboard',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

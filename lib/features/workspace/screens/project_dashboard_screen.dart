import 'package:flutter/material.dart';
import '../../project/models/project.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class ProjectDashboardScreen extends StatelessWidget {
  final Project project;

  const ProjectDashboardScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProjectHeader(project: project),
                  const SizedBox(height: AppConstants.spacingLg),
                  _ProgressSection(),
                  const SizedBox(height: AppConstants.spacingLg),
                  _TechnicalStackSection(project: project),
                  const SizedBox(height: AppConstants.spacingLg),
                  _QuickActionsSection(),
                  const SizedBox(height: AppConstants.spacingLg),
                  _RecentActivitySection(),
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

class _ProjectHeader extends StatelessWidget {
  final Project project;
  const _ProjectHeader({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
                  Text(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: project.status),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KindleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Development Progress', subtitle: 'Phases 1-2 of 6 complete'),
          const SizedBox(height: AppConstants.spacingSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: const LinearProgressIndicator(
              value: 0.35,
              minHeight: 8,
              backgroundColor: Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(context, 'Tasks Done', '4'),
              _buildStat(context, 'In Progress', '2'),
              _buildStat(context, 'Total Files', '12'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _TechnicalStackSection extends StatelessWidget {
  final Project project;
  const _TechnicalStackSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KindleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Technology', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.layers_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(project.selectedTechnology ?? 'Not Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: KindleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Platforms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.devices, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('${project.platforms.length} Platforms', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Quick Actions'),
        const SizedBox(height: AppConstants.spacingSm),
        Wrap(
          spacing: AppConstants.spacingMd,
          runSpacing: AppConstants.spacingMd,
          children: [
            _ActionChip(icon: Icons.add, label: 'Requirement', onTap: () {}),
            _ActionChip(icon: Icons.edit_note, label: 'Edit Idea', onTap: () {}),
            _ActionChip(icon: Icons.play_arrow, label: 'Resume Plan', onTap: () {}),
            _ActionChip(icon: Icons.code, label: 'View Code', onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade200),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Recent Activity'),
        KindleCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.auto_awesome,
                title: 'Architecture Sparked',
                time: '2 hours ago',
                isLast: false,
              ),
              _ActivityItem(
                icon: Icons.assignment_turned_in,
                title: 'Requirements Formalized',
                time: '5 hours ago',
                isLast: false,
              ),
              _ActivityItem(
                icon: Icons.chat_bubble_outline,
                title: 'Discovery Conversation Complete',
                time: 'Yesterday',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final bool isLast;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.time,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary, size: 20),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
          dense: true,
        ),
        if (!isLast) const Divider(height: 1, indent: 56),
      ],
    );
  }
}

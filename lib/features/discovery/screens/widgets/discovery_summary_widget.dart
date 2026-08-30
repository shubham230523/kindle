import 'package:flutter/material.dart';
import '../../../project/models/project.dart';
import '../../../project/screens/project_summary_screen.dart';
import '../../../../shared/widgets/kindle_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class DiscoverySummaryWidget extends StatelessWidget {
  final Project project;

  const DiscoverySummaryWidget({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KindleCard(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, color: AppColors.primary),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(
                      child: Text(
                        "Product Summary",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppConstants.spacingLg),
                _buildInfoItem(context, "Suggested Name", project.name),
                _buildInfoItem(context, "Description", project.description),
                const SizedBox(height: AppConstants.spacingMd),
                const SectionTitle(title: "Key Features"),
                ...project.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                          const SizedBox(width: AppConstants.spacingSm),
                          Text(feature.name),
                        ],
                      ),
                    )),
                const SizedBox(height: AppConstants.spacingMd),
                const SectionTitle(title: "Requirements"),
                ...project.requirements.map((req) => Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
                      child: Text("• ${req.title}: ${req.description}"),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectSummaryScreen(project: project),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
            child: const Text("Create Project Workspace"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

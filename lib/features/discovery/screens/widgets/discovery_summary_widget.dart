import 'package:flutter/material.dart';
import '../../../project/models/project.dart';
import '../../../project/screens/project_summary_screen.dart';
import '../../../../shared/widgets/kindle_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class DiscoverySummaryWidget extends StatefulWidget {
  final Project project;
  final Function(String)? onNameChanged;

  const DiscoverySummaryWidget({
    super.key,
    required this.project,
    this.onNameChanged,
  });

  @override
  State<DiscoverySummaryWidget> createState() => _DiscoverySummaryWidgetState();
}

class _DiscoverySummaryWidgetState extends State<DiscoverySummaryWidget> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descriptionController = TextEditingController(text: widget.project.description);
  }

  @override
  void didUpdateWidget(DiscoverySummaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.name != widget.project.name && 
        _nameController.text != widget.project.name) {
      _nameController.text = widget.project.name;
    }
    if (oldWidget.project.description != widget.project.description && 
        _descriptionController.text != widget.project.description) {
      _descriptionController.text = widget.project.description;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
                
                // Editable Project Name
                _buildLabel(context, "App Name"),
                const SizedBox(height: AppConstants.spacingSm), // Increased spacing
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Enter app name..."),
                  onChanged: widget.onNameChanged,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Editable Description
                _buildLabel(context, "Description"),
                const SizedBox(height: AppConstants.spacingSm), // Increased spacing
                TextFormField(
                  controller: _descriptionController,
                  maxLines: null, // Allows auto-expansion
                  decoration: _buildInputDecoration("Enter app description..."),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                if (widget.project.features.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingLg),
                  const SectionTitle(title: "Key Features"),
                  const SizedBox(height: AppConstants.spacingSm),
                  ...widget.project.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                            const SizedBox(width: AppConstants.spacingSm),
                            Expanded(
                              child: Text(
                                feature.name + (feature.description != feature.name ? ": ${feature.description}" : ""),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                if (widget.project.requirements.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingMd),
                  const SectionTitle(title: "Requirements"),
                  const SizedBox(height: AppConstants.spacingSm),
                  ...widget.project.requirements.map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spacingXs),
                        child: Text(
                          req.title == req.description 
                            ? "• ${req.title}"
                            : "• ${req.title}: ${req.description}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectSummaryScreen(project: widget.project),
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

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingMd, // Better vertical padding
        horizontal: AppConstants.spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}

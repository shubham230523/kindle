import 'package:flutter/material.dart';
import '../../../project/models/build_analysis.dart';
import '../../../../shared/widgets/kindle_card.dart';
import '../../../../shared/widgets/kindle_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class BuildAnalysisWidget extends StatelessWidget {
  final BuildFailureAnalysis analysis;
  final VoidCallback onRetry;
  final VoidCallback onFix;

  const BuildAnalysisWidget({
    super.key,
    required this.analysis,
    required this.onRetry,
    required this.onFix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KindleCard(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Failure Analysis',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        Text(
                          '${(analysis.confidence * 100).toInt()}% Confidence',
                          style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: AppConstants.spacingLg),
              _buildSection(context, 'Error Summary', analysis.errorSummary, Icons.error_outline, Colors.redAccent),
              const SizedBox(height: AppConstants.spacingMd),
              _buildSection(context, 'Likely Cause', analysis.likelyCause, Icons.psychology_outlined, Colors.blue),
              const SizedBox(height: AppConstants.spacingMd),
              _buildSection(context, 'Suggested Solution', analysis.suggestedSolution, Icons.lightbulb_outline, Colors.amber),
              const SizedBox(height: AppConstants.spacingMd),
              if (analysis.affectedFiles.isNotEmpty) ...[
                const Text(
                  'Affected Files:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: analysis.affectedFiles.map((f) => Chip(
                    label: Text(f, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide.none,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Row(
          children: [
            Expanded(
              child: KindleButton(
                text: 'Ask Debug Agent to Fix',
                onPressed: onFix,
                icon: Icons.bolt,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: KindleButton.secondary(
                text: 'Retry Build',
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/discovery_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class DiscoveryStageIndicator extends StatelessWidget {
  final DiscoveryStage currentStage;

  const DiscoveryStageIndicator({
    super.key,
    required this.currentStage,
  });

  String _getStageText(DiscoveryStage stage) {
    switch (stage) {
      case DiscoveryStage.understandingIdea:
        return "Understanding Idea";
      case DiscoveryStage.gatheringRequirements:
        return "Gathering Requirements";
      case DiscoveryStage.definingFeatures:
        return "Defining Features";
      case DiscoveryStage.selectingTech:
        return "Selecting Technology";
      case DiscoveryStage.planning:
        return "Planning";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                _getStageText(currentStage),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          Text(
            "${DiscoveryStage.values.indexOf(currentStage) + 1} / ${DiscoveryStage.values.length}",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

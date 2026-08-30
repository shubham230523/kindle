import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingXs,
          horizontal: AppConstants.spacingSm,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingSm + 4,
          horizontal: AppConstants.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.agentBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusMd),
            topRight: Radius.circular(AppConstants.radiusMd),
            bottomRight: Radius.circular(AppConstants.radiusMd),
            bottomLeft: Radius.circular(0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double progress = (_controller.value - (index * 0.2)) % 1.0;
                final double opacity = 0.3 + (math.sin(progress * 2 * math.pi).abs() * 0.5);
                
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

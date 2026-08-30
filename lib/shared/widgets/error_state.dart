import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'kindle_button.dart';

class KindleErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const KindleErrorState({
    super.key,
    this.title = 'Oops! Something went wrong',
    this.message = 'We couldn\'t complete your request. Please try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacingLg),
              KindleButton(
                text: 'Retry',
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

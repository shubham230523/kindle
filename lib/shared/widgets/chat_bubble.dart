import 'package:flutter/material.dart';
import '../models/message.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingXs,
            horizontal: AppConstants.spacingSm,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingSm + 2,
            horizontal: AppConstants.spacingMd - 2,
          ),
          decoration: BoxDecoration(
            color: message.isUser ? AppColors.userBubble : AppColors.agentBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppConstants.radiusMd),
              topRight: const Radius.circular(AppConstants.radiusMd),
              bottomLeft: message.isUser
                  ? const Radius.circular(AppConstants.radiusMd)
                  : const Radius.circular(0),
              bottomRight: message.isUser
                  ? const Radius.circular(0)
                  : const Radius.circular(AppConstants.radiusMd),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

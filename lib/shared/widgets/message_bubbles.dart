import 'package:flutter/material.dart';
import '../models/message.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class UserMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const UserMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return _BaseMessageBubble(
      content: message.content,
      isUser: true,
      status: message.status,
    );
  }
}

class AiMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const AiMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return _BaseMessageBubble(
      content: message.content,
      isUser: false,
    );
  }
}

class _BaseMessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final MessageStatus? status;

  const _BaseMessageBubble({
    required this.content,
    required this.isUser,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
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
            color: isUser ? AppColors.userBubble : AppColors.agentBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppConstants.radiusMd),
              topRight: const Radius.circular(AppConstants.radiusMd),
              bottomLeft: isUser
                  ? const Radius.circular(AppConstants.radiusMd)
                  : const Radius.circular(0),
              bottomRight: isUser
                  ? const Radius.circular(0)
                  : const Radius.circular(AppConstants.radiusMd),
            ),
          ),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyle(
                  color: isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              if (isUser && status != null) ...[
                const SizedBox(height: 2),
                _StatusIndicator(status: status!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final MessageStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white70),
        );
      case MessageStatus.error:
        return const Icon(Icons.error_outline, size: 12, color: Colors.redAccent);
      case MessageStatus.sent:
        return const SizedBox.shrink();
    }
  }
}

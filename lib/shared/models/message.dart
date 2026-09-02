enum MessageSender { user, ai }

enum MessageStatus { sending, sent, error }

class ChatMessage {
  final String id;
  final String content;
  final String? reasoningDetails;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.content,
    this.reasoningDetails,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;

  ChatMessage copyWith({
    String? content,
    String? reasoningDetails,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      reasoningDetails: reasoningDetails ?? this.reasoningDetails,
      sender: sender,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }
}

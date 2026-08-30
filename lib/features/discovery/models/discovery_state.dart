import '../../../shared/models/message.dart';

enum DiscoveryStage {
  initialIdea,
  understanding,
  clarification,
  requirementsGathering,
  discoveryComplete,
}

class DiscoveryState {
  final List<ChatMessage> messages;
  final bool isAiTyping;
  final String? errorMessage;
  final DiscoveryStage stage;

  const DiscoveryState({
    this.messages = const [],
    this.isAiTyping = false,
    this.errorMessage,
    this.stage = DiscoveryStage.initialIdea,
  });

  DiscoveryState copyWith({
    List<ChatMessage>? messages,
    bool? isAiTyping,
    String? errorMessage,
    DiscoveryStage? stage,
  }) {
    return DiscoveryState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      errorMessage: errorMessage ?? this.errorMessage,
      stage: stage ?? this.stage,
    );
  }
}

import '../../../shared/models/message.dart';

enum DiscoveryStage {
  initialIdea,
  reversePrompting,
  discoveryComplete,
}

class DiscoveryState {
  final List<ChatMessage> messages;
  final bool isAiTyping;
  final String? errorMessage;
  final DiscoveryStage stage;
  final Map<String, String> answers;
  final int currentQuestionIndex;
  final double progress;

  const DiscoveryState({
    this.messages = const [],
    this.isAiTyping = false,
    this.errorMessage,
    this.stage = DiscoveryStage.initialIdea,
    this.answers = const {},
    this.currentQuestionIndex = -1,
    this.progress = 0.0,
  });

  DiscoveryState copyWith({
    List<ChatMessage>? messages,
    bool? isAiTyping,
    String? errorMessage,
    DiscoveryStage? stage,
    Map<String, String>? answers,
    int? currentQuestionIndex,
    double? progress,
  }) {
    return DiscoveryState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      errorMessage: errorMessage ?? this.errorMessage,
      stage: stage ?? this.stage,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      progress: progress ?? this.progress,
    );
  }
}

import '../../../shared/models/message.dart';
import '../../project/models/project.dart';

enum DiscoveryStage {
  understandingIdea,
  gatheringRequirements,
  definingFeatures,
  selectingTech,
  planning,
  summary,
}

class DiscoveryState {
  final List<ChatMessage> messages;
  final bool isAiTyping;
  final String? errorMessage;
  final DiscoveryStage stage;
  final Map<String, String> answers;
  final int currentQuestionIndex;
  final double progress;
  final Project? generatedProject;

  const DiscoveryState({
    this.messages = const [],
    this.isAiTyping = false,
    this.errorMessage,
    this.stage = DiscoveryStage.understandingIdea,
    this.answers = const {},
    this.currentQuestionIndex = -1,
    this.progress = 0.0,
    this.generatedProject,
  });

  DiscoveryState copyWith({
    List<ChatMessage>? messages,
    bool? isAiTyping,
    String? errorMessage,
    DiscoveryStage? stage,
    Map<String, String>? answers,
    int? currentQuestionIndex,
    double? progress,
    Project? generatedProject,
  }) {
    return DiscoveryState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      errorMessage: errorMessage ?? this.errorMessage,
      stage: stage ?? this.stage,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      progress: progress ?? this.progress,
      generatedProject: generatedProject ?? this.generatedProject,
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/models/message.dart';
import '../models/discovery_state.dart';

class DiscoveryViewModel extends ChangeNotifier {
  DiscoveryState _state = const DiscoveryState();
  DiscoveryState get state => _state;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toIso8601String(),
      content: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    _state = _state.copyWith(
      messages: [..._state.messages, userMessage],
      isAiTyping: true,
      errorMessage: null,
    );
    notifyListeners();

    _processConversation();
  }

  void _processConversation() {
    // Determine the next stage and response
    final currentStage = _state.stage;
    DiscoveryStage nextStage = currentStage;
    String responseContent = "";

    switch (currentStage) {
      case DiscoveryStage.initialIdea:
        nextStage = DiscoveryStage.understanding;
        responseContent = "That sounds like a great starting point! To make sure I understand, are you looking to build this as a mobile-first experience or something else?";
        break;
      case DiscoveryStage.understanding:
        nextStage = DiscoveryStage.clarification;
        responseContent = "Got it. Could you clarify who the primary users would be? Understanding the audience will help me suggest the right features.";
        break;
      case DiscoveryStage.clarification:
        nextStage = DiscoveryStage.requirementsGathering;
        responseContent = "That makes sense. Now, let's talk about requirements. What are the 'must-have' functionalities for the first version?";
        break;
      case DiscoveryStage.requirementsGathering:
        nextStage = DiscoveryStage.discoveryComplete;
        responseContent = "Excellent. I have a clear picture now. I've gathered all the initial requirements and we're ready to start the project workspace. Should we proceed?";
        break;
      case DiscoveryStage.discoveryComplete:
        responseContent = "The discovery is complete! You can now view your project details in the workspace.";
        break;
    }

    _simulateAiResponse(responseContent, nextStage);
  }

  void _simulateAiResponse(String content, DiscoveryStage nextStage) {
    Timer(const Duration(seconds: 2), () {
      final aiMessage = ChatMessage(
        id: DateTime.now().toIso8601String(),
        content: content,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      _state = _state.copyWith(
        messages: [..._state.messages, aiMessage],
        isAiTyping: false,
        stage: nextStage,
      );
      notifyListeners();
    });
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}

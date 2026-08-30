import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/models/message.dart';
import '../models/discovery_state.dart';

class DiscoveryViewModel extends ChangeNotifier {
  DiscoveryState _state = const DiscoveryState();
  DiscoveryState get state => _state;

  final List<String> _questions = [
    "Who is the target user for this application?",
    "What specific problem does the application solve for these users?",
    "What are the top 3 core features you envision?",
    "Will your application require user authentication (login/signup)?",
    "Does the application need a backend service for data persistence or real-time features?",
    "Which platforms should we target? (Mobile, Web, Desktop, or all?)",
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toIso8601String(),
      content: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    // Store answer if we are in reverse prompting stage
    Map<String, String> updatedAnswers = Map.from(_state.answers);
    if (_state.stage == DiscoveryStage.reversePrompting && _state.currentQuestionIndex >= 0) {
      updatedAnswers[_questions[_state.currentQuestionIndex]] = text;
    }

    _state = _state.copyWith(
      messages: [..._state.messages, userMessage],
      isAiTyping: true,
      errorMessage: null,
      answers: updatedAnswers,
    );
    notifyListeners();

    _processConversation();
  }

  void _processConversation() {
    final currentStage = _state.stage;
    DiscoveryStage nextStage = currentStage;
    String responseContent = "";
    int nextQuestionIndex = _state.currentQuestionIndex;

    if (currentStage == DiscoveryStage.initialIdea) {
      nextStage = DiscoveryStage.reversePrompting;
      nextQuestionIndex = 0;
      responseContent = "That's an interesting idea! To help me understand better, I'd like to ask a few questions. First, ${_questions[0]}";
    } else if (currentStage == DiscoveryStage.reversePrompting) {
      nextQuestionIndex++;
      if (nextQuestionIndex < _questions.length) {
        responseContent = "Got it. Next: ${_questions[nextQuestionIndex]}";
      } else {
        nextStage = DiscoveryStage.discoveryComplete;
        responseContent = "Thank you! I've gathered all the information I need. I'm now processing your requirements to generate a project roadmap.";
      }
    } else {
      responseContent = "The discovery is complete! You can now view your project details.";
    }

    final double progress = nextStage == DiscoveryStage.discoveryComplete 
        ? 1.0 
        : (nextQuestionIndex + 1) / (_questions.length + 1);

    _simulateAiResponse(responseContent, nextStage, nextQuestionIndex, progress);
  }

  void _simulateAiResponse(String content, DiscoveryStage nextStage, int nextQuestionIndex, double progress) {
    Timer(const Duration(seconds: 1), () {
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
        currentQuestionIndex: nextQuestionIndex,
        progress: progress,
      );
      notifyListeners();
    });
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}

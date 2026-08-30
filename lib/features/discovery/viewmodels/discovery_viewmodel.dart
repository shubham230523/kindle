import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/models/message.dart';
import '../models/discovery_state.dart';
import '../../project/models/project.dart';
import '../../project/models/requirement.dart';
import '../../project/models/feature.dart';

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

    // Store answer if we are currently asking questions
    Map<String, String> updatedAnswers = Map.from(_state.answers);
    if (_state.currentQuestionIndex >= 0 && _state.currentQuestionIndex < _questions.length) {
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
    DiscoveryStage nextStage = _state.stage;
    String responseContent = "";
    int nextQuestionIndex = _state.currentQuestionIndex;

    if (_state.currentQuestionIndex == -1) {
      // First user message (Initial Idea)
      nextQuestionIndex = 0;
      nextStage = DiscoveryStage.gatheringRequirements;
      responseContent = "That's an interesting idea! To help me understand better, I'd like to ask a few questions. First, ${_questions[0]}";
    } else {
      nextQuestionIndex++;
      if (nextQuestionIndex < _questions.length) {
        // Update stage based on question index
        if (nextQuestionIndex == 2) {
          nextStage = DiscoveryStage.definingFeatures;
        } else if (nextQuestionIndex == 3) {
          nextStage = DiscoveryStage.selectingTech;
        }
        responseContent = "Got it. Next: ${_questions[nextQuestionIndex]}";
      } else {
        nextStage = DiscoveryStage.planning;
        responseContent = "Thank you! I've gathered all the information I need. I'm now processing your requirements to generate a project roadmap.";
        
        // Final transition to summary
        _generateSummary();
        return;
      }
    }

    final double progress = nextStage == DiscoveryStage.planning || nextStage == DiscoveryStage.summary
        ? 1.0 
        : (nextQuestionIndex + 1) / (_questions.length + 1);

    _simulateAiResponse(responseContent, nextStage, nextQuestionIndex, progress);
  }

  void _generateSummary() {
    // Show AI message first
    _simulateAiResponse(
      "I've analyzed your requirements and generated a project summary. Here's what I've sparkled for you!",
      DiscoveryStage.summary,
      _questions.length,
      1.0,
    );

    // Generate mock project based on answers
    final targetUser = _state.answers[_questions[0]] ?? "General Users";
    final problem = _state.answers[_questions[1]] ?? "General inefficiency";
    final featuresText = _state.answers[_questions[2]] ?? "Feature A, Feature B, Feature C";
    
    final mockProject = Project(
      id: "proj_${DateTime.now().millisecondsSinceEpoch}",
      name: "Kindle Spark App",
      description: "A solution focused on solving: $problem",
      targetUsers: targetUser,
      problemStatement: problem,
      status: ProjectStatus.draft,
      createdAt: DateTime.now(),
      requirements: [
        Requirement(
          id: "req1",
          title: "User Experience",
          description: "Optimized for $targetUser",
          priority: RequirementPriority.high,
        ),
        Requirement(
          id: "req2",
          title: "Core Solution",
          description: problem,
          priority: RequirementPriority.high,
        ),
      ],
      features: featuresText.split(',').map((f) => Feature(
        id: "feat_${f.trim()}",
        name: f.trim(),
        description: "Core functionality for ${f.trim()}",
        category: "Core",
      )).toList(),
    );

    Timer(const Duration(seconds: 2), () {
      _state = _state.copyWith(generatedProject: mockProject);
      notifyListeners();
    });
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

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/models/message.dart';
import '../models/discovery_state.dart';
import '../models/discovery_backend_result.dart';
import '../../project/models/project.dart';
import '../../project/models/requirement.dart';
import '../../../core/services/discovery_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final DiscoveryService _discoveryService;
  
  DiscoveryState _state = const DiscoveryState();
  DiscoveryState get state => _state;

  String? _lastUserMessage;

  DiscoveryViewModel({DiscoveryService? discoveryService}) 
      : _discoveryService = discoveryService ?? DiscoveryService();

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _lastUserMessage = text;

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

    await _callBackend(text);
  }

  Future<void> _callBackend(String idea) async {
    try {
      final result = await _discoveryService.processIdea(
        idea, 
        _state.messages.where((m) => m.sender != MessageSender.user || m.content != idea).toList(),
      );

      _handleBackendResponse(result);
    } catch (e) {
      _state = _state.copyWith(
        isAiTyping: false,
        errorMessage: 'Connection failed. Please check if the backend is running.',
      );
      notifyListeners();
    }
  }

  void retryLastMessage() {
    if (_lastUserMessage != null) {
      _state = _state.copyWith(
        isAiTyping: true,
        errorMessage: null,
      );
      notifyListeners();
      _callBackend(_lastUserMessage!);
    }
  }

  void _handleBackendResponse(DiscoveryBackendResult result) {
    final aiMessage = ChatMessage(
      id: DateTime.now().toIso8601String(),
      content: result.currentQuestion ?? "Discovery complete!",
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );

    DiscoveryStage nextStage = _state.stage;
    if (result.isDiscoveryComplete) {
      nextStage = DiscoveryStage.summary;
      _generateSummaryFromBackend(result);
    } else {
      // Map confidence to stages for progress indicator
      if (result.confidence < 0.3) {
        nextStage = DiscoveryStage.understandingIdea;
      } else if (result.confidence < 0.6) {
        nextStage = DiscoveryStage.gatheringRequirements;
      } else {
        nextStage = DiscoveryStage.definingFeatures;
      }
    }

    _state = _state.copyWith(
      messages: [..._state.messages, aiMessage],
      isAiTyping: false,
      stage: nextStage,
      progress: result.confidence,
    );
    notifyListeners();
  }

  void _generateSummaryFromBackend(DiscoveryBackendResult result) {
    // Generate a project based on the structured requirements from backend
    final mockProject = Project(
      id: "proj_${DateTime.now().millisecondsSinceEpoch}",
      name: "Sparked App",
      description: result.understandingSummary,
      status: ProjectStatus.draft,
      createdAt: DateTime.now(),
      requirements: result.discoveredRequirements.map((r) => Requirement(
        id: DateTime.now().toString(),
        title: r,
        description: r,
        priority: RequirementPriority.high,
      )).toList(),
      features: [], // Backend could return these too in the future
      userStories: [],
    );

    _state = _state.copyWith(generatedProject: mockProject);
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}

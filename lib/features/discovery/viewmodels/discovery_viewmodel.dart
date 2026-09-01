import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/models/message.dart';
import '../models/discovery_state.dart';
import '../models/discovery_backend_result.dart';
import '../../project/models/project.dart';
import '../../project/models/requirement.dart';
import '../../project/models/feature.dart';
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
    
    final List<Feature> features = [];
    final List<Requirement> requirements = [];

    for (var r in result.discoveredRequirements) {
      if (r.toLowerCase().startsWith('feature:')) {
        final featureText = r.substring(8).trim();
        features.add(Feature(
          id: DateTime.now().millisecondsSinceEpoch.toString() + features.length.toString(),
          name: featureText.contains(':') ? featureText.split(':')[0].trim() : featureText,
          description: featureText.contains(':') ? featureText.split(':')[1].trim() : featureText,
          category: 'Core',
        ));
      } else {
        requirements.add(Requirement(
          id: DateTime.now().millisecondsSinceEpoch.toString() + requirements.length.toString(),
          title: r.contains(':') ? r.split(':')[0].trim() : r,
          description: r.contains(':') ? r.split(':').sublist(1).join(':').trim() : r,
          priority: RequirementPriority.high,
        ));
      }
    }

    final mockProject = Project(
      id: "proj_${DateTime.now().millisecondsSinceEpoch}",
      name: "Sparked App",
      description: result.understandingSummary,
      status: ProjectStatus.draft,
      createdAt: DateTime.now(),
      requirements: requirements,
      features: features,
      userStories: [],
    );

    _state = _state.copyWith(generatedProject: mockProject);
  }

  void updateProjectName(String newName) {
    if (_state.generatedProject != null) {
      _state = _state.copyWith(
        generatedProject: _state.generatedProject!.copyWith(name: newName),
      );
      notifyListeners();
    }
  }

  void skipDiscovery() {
    final result = DiscoveryBackendResult(
      understandingSummary: 'A robust To-Do application for cross-device productivity. SyncTasks allows users to manage their daily schedules with real-time cloud synchronization between mobile and desktop.',
      currentQuestion: null,
      discoveredRequirements: [
        'Target audience: Productive professionals and students',
        'Problem: Difficulty keeping task lists updated across multiple devices.',
        'Platforms: Android and iOS',
        'Feature: Real-time Cloud Sync',
        'Feature: Offline Task Creation',
        'Feature: Push notifications for deadlines',
        'Feature: Categorization and Priority Tagging',
        'User Authentication: Multi-device session management',
      ],
      missingInformation: [],
      confidence: 1.0,
      isDiscoveryComplete: true,
    );

    _state = _state.copyWith(
      stage: DiscoveryStage.summary,
      progress: 1.0,
      isAiTyping: false,
    );
    _generateSummaryFromBackend(result);
    
    // Explicitly update extra fields for dummy data
    if (_state.generatedProject != null) {
      _state = _state.copyWith(
        generatedProject: _state.generatedProject!.copyWith(
          name: "SyncTasks",
          targetUsers: "Productive professionals and students",
          problemStatement: "Difficulty keeping task lists updated across multiple devices.",
          platforms: ["android", "ios"],
        ),
      );
    }
    
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}

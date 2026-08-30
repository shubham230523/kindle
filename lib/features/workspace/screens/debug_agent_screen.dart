import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kindle_card.dart';
import '../../../shared/widgets/kindle_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';

class DebugAgentScreen extends StatefulWidget {
  const DebugAgentScreen({super.key});

  @override
  State<DebugAgentScreen> createState() => _DebugAgentScreenState();
}

class _DebugAgentScreenState extends State<DebugAgentScreen> {
  int _currentStep = 0;
  bool _isRunning = false;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Issue Detected',
      'icon': Icons.bug_report_outlined,
      'description': 'Automated test suite reported a failure in LoginScreen widget tests.',
      'details': 'Error: Expected: clickable, Actual: disabled\nLocation: login_screen_test.dart:42',
    },
    {
      'title': 'Analysis',
      'icon': Icons.search,
      'description': 'Scanning related source files and build configurations...',
      'details': 'Analyzed: lib/features/auth/screens/login_screen.dart\nAnalyzed: lib/features/auth/viewmodels/auth_viewmodel.dart',
    },
    {
      'title': 'Root Cause Hypothesis',
      'icon': Icons.psychology_outlined,
      'description': 'The login button remains disabled because the "isLoading" state in AuthViewModel is never reset after a failed attempt.',
      'details': 'Hypothesis confidence: 94%',
    },
    {
      'title': 'Proposed Fix',
      'icon': Icons.build_circle_outlined,
      'description': 'Add a finally block in the login method to ensure isLoading is set to false.',
      'details': 'File: auth_viewmodel.dart\nLines: +12, -2',
    },
    {
      'title': 'Apply Fix',
      'icon': Icons.auto_awesome,
      'description': 'Executing file modifications and staging changes.',
      'details': 'Modification complete. Git index updated.',
    },
    {
      'title': 'Rebuild',
      'icon': Icons.sync,
      'description': 'Triggering a hot-reload build to verify changes.',
      'details': 'Build successful (Duration: 1.2s)',
    },
    {
      'title': 'Retest',
      'icon': Icons.fact_check_outlined,
      'description': 'Running affected test cases...',
      'details': 'Test result: PASSED (1/1)',
    },
  ];

  void _startDebugging() async {
    setState(() {
      _isRunning = true;
      _currentStep = 0;
      _logs.clear();
      _logs.add('--- Debug Agent Session Started ---');
    });

    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_isRunning) return;
      
      setState(() {
        _currentStep = i;
        _logs.add('Step ${i + 1}: ${_steps[i]['title']}');
        _logs.add('>> ${_steps[i]['description']}');
      });
      _scrollToBottom();
    }

    setState(() {
      _isRunning = false;
      _logs.add('--- Debugging Complete: Issue Resolved ---');
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autonomous Debugging'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAgentHeader(),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Timeline
                      Expanded(
                        flex: 3,
                        child: _buildTimeline(),
                      ),
                      const SizedBox(width: AppConstants.spacingLg),
                      // Log Terminal
                      Expanded(
                        flex: 2,
                        child: _buildTerminal(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                KindleButton(
                  text: _isRunning ? 'Debugging in progress...' : 'Initiate Debug Cycle',
                  onPressed: _isRunning ? () {} : _startDebugging,
                  isLoading: _isRunning,
                  icon: Icons.bolt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgentHeader() {
    return KindleCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.bug_report, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Debug Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  _isRunning ? 'Autonomous fixing active' : 'Waiting for issue...',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (_isRunning) const CircularProgressIndicator(strokeWidth: 2),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        final isCompleted = index < _currentStep;
        final isActive = index == _currentStep && _isRunning;
        final isPending = index > _currentStep || (!isActive && !isCompleted);

        return Opacity(
          opacity: isPending ? 0.4 : 1.0,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Colors.green : (isActive ? AppColors.primary : Colors.grey.shade300),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : step['icon'],
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      if (index < _steps.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: isCompleted ? Colors.green : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppColors.primary : null,
                          ),
                        ),
                        Text(
                          step['description'],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isActive || isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              step['details'],
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTerminal() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AGENT LOGS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _logs[index],
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

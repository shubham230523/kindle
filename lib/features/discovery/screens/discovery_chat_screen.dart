import 'package:flutter/material.dart';
import '../../../shared/widgets/message_bubbles.dart';
import '../../../shared/widgets/typing_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../viewmodels/discovery_viewmodel.dart';
import 'widgets/stage_indicator.dart';

class DiscoveryChatScreen extends StatefulWidget {
  const DiscoveryChatScreen({super.key});

  @override
  State<DiscoveryChatScreen> createState() => _DiscoveryChatScreenState();
}

class _DiscoveryChatScreenState extends State<DiscoveryChatScreen> {
  final DiscoveryViewModel _viewModel = DiscoveryViewModel();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _viewModel.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (_viewModel.state.messages.isNotEmpty || _viewModel.state.isAiTyping) {
      _scrollToBottom();
    }
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

  void _handleSend() {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      _viewModel.sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindle Discovery'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final state = _viewModel.state;

          if (state.errorMessage != null) {
            return KindleErrorState(
              message: state.errorMessage!,
              onRetry: () => _viewModel.clearError(),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: Column(
                children: [
                  DiscoveryStageIndicator(currentStage: state.stage),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingSm,
                      ),
                      itemCount: state.messages.length + (state.isAiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.messages.length && state.isAiTyping) {
                          return const TypingIndicator();
                        }
                        final message = state.messages[index];
                        return message.isUser
                            ? UserMessageBubble(message: message)
                            : AiMessageBubble(message: message);
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        if (ResponsiveLayout.isDesktop(context))
                          BoxShadow(
                            color: AppColors.inputShadow,
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Ask Kindle something...',
                            ),
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSm),
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: AppColors.textOnPrimary),
                            onPressed: _handleSend,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../shared/models/message.dart';
import '../../../shared/widgets/message_bubbles.dart';
import '../../../shared/widgets/typing_indicator.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toIso8601String(),
      content: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(userMessage);
      _isAiTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate agent response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add(
            ChatMessage(
              id: DateTime.now().toIso8601String(),
              content: "I'm your Kindle agent. How can I help you spark something today?",
              sender: MessageSender.ai,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
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
        title: const Text('Kindle Agent'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  itemCount: _messages.length + (_isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isAiTyping) {
                      return const TypingIndicator();
                    }
                    final message = _messages[index];
                    if (message.isUser) {
                      return UserMessageBubble(message: message);
                    } else {
                      return AiMessageBubble(message: message);
                    }
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
                          hintText: 'Type a message...',
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.textOnPrimary),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

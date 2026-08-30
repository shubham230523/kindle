import 'package:flutter/material.dart';
import '../../../shared/models/message.dart';
import '../../../shared/widgets/chat_bubble.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          text: _controller.text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate agent response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add(
            Message(
              text: "I'm your Kindle agent. How can I help you spark something today?",
              isUser: false,
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
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: _messages[index]);
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

import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/chat_message_entity.dart';
import 'package:beesports/blocs/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LobbyChatScreen extends StatefulWidget {
  final String lobbyId;
  const LobbyChatScreen({super.key, required this.lobbyId});

  @override
  State<LobbyChatScreen> createState() => _LobbyChatScreenState();
}

class _LobbyChatScreenState extends State<LobbyChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.id;
    }
    context.read<ChatBloc>().add(LoadMessages(widget.lobbyId));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentUserId == null) return;
    context.read<ChatBloc>().add(
          SendMessage(widget.lobbyId, _currentUserId!, text),
        );
    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby Chat')),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatError) {
                  return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: AppColors.error)),
                  );
                }
                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet. Say hi! 👋',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) => _MessageBubble(
                      message: state.messages[index],
                      isOwnMessage:
                          state.messages[index].senderId == _currentUserId,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _InputBar(
            controller: _controller,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isOwnMessage;

  const _MessageBubble({
    required this.message,
    required this.isOwnMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage)
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                (message.senderName ?? '?')[0].toUpperCase(),
                style: const TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),
          if (!isOwnMessage) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isOwnMessage ? const Radius.circular(16) : Radius.zero,
                  bottomRight:
                      isOwnMessage ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isOwnMessage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  Text(message.content),
                  const SizedBox(height: 4),
                  Text(
                    '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondaryDark.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondaryDark.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black, size: 20),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

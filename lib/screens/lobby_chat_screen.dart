import 'package:beesports/app/app_theme.dart';
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
    if (authState is Authenticated) _currentUserId = authState.user.id;
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
    context
        .read<ChatBloc>()
        .add(SendMessage(widget.lobbyId, _currentUserId!, text));
    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Lobby Chat',
            style: AppTextStyles.sectionTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neonGreen),
      ),
      body: Column(children: [
        Expanded(
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded) _scrollToBottom();
            },
            builder: (context, state) {
              if (state is ChatLoading) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.neonGreen));
              }
              if (state is ChatError) {
                return Center(
                    child: Text(state.message,
                        style: AppTextStyles.error));
              }
              if (state is ChatLoaded) {
                if (state.messages.isEmpty) {
                  return Center(
                    child: Text('No messages yet. Say hi! 👋',
                        style:
                            AppTextStyles.bodySecondary),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(DesignConfig.spacingXl,
                      DesignConfig.spacingXl, DesignConfig.spacingXl, 0),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) => _MessageBubble(
                    message: state.messages[index],
                    isOwn: state.messages[index].senderId == _currentUserId,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        _InputBar(controller: _controller, onSend: _send),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isOwn;
  const _MessageBubble({required this.message, required this.isOwn});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignConfig.spacingSm),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: DesignConfig.spacingMd, vertical: DesignConfig.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(DesignConfig.roundedLg),
            ),
            child: Text(message.content,
                style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic)),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignConfig.spacingSm),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: AppColors.neonGreen, shape: BoxShape.circle),
              child: Center(
                child: Text((message.senderName ?? '?')[0].toUpperCase(),
                    style: AppTextStyles.onAccent),
              ),
            ),
            const SizedBox(width: DesignConfig.spacingSm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: DesignConfig.spacingLg, vertical: DesignConfig.spacingMd),
              decoration: BoxDecoration(
                color: isOwn ? AppColors.neonGreen : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(DesignConfig.roundedLg),
                  topRight: const Radius.circular(DesignConfig.roundedLg),
                  bottomLeft: isOwn ? const Radius.circular(DesignConfig.roundedLg) : Radius.zero,
                  bottomRight: isOwn ? Radius.zero : const Radius.circular(DesignConfig.roundedLg),
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isOwn)
                      Padding(
                        padding: const EdgeInsets.only(bottom: DesignConfig.spacingXs),
                        child: Text(message.senderName ?? '[N/A]',
                            style: AppTextStyles.chatTimestamp),
                      ),
                    Text(message.content,
                        style: (isOwn
                                ? AppTextStyles.onAccentBody
                                : AppTextStyles.accentBody)
                            .copyWith(fontSize: DesignConfig.bodyMd.fontSize)),
                    const SizedBox(height: DesignConfig.spacingXs),
                    Text(
                        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.chatMeta),
                  ]),
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
      padding: const EdgeInsets.fromLTRB(DesignConfig.spacingLg, DesignConfig.spacingSm, DesignConfig.spacingSm, DesignConfig.spacingLg),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.bodySecondary,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignConfig.roundedXl),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: DesignConfig.spacingLg, vertical: DesignConfig.spacingMd),
              ),
              style: AppTextStyles.sectionTitle,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: DesignConfig.spacingSm),
          Container(
            decoration: const BoxDecoration(
                color: AppColors.neonGreen, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.onAccent, size: 20),
              onPressed: onSend,
            ),
          ),
        ]),
      ),
    );
  }
}



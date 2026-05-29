import 'package:beesports/app/app_colors.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/models/chat_message_entity.dart';
import 'package:beesports/blocs/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500, color: AppColors.neonGreen)),
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
                        style: GoogleFonts.inter(color: AppColors.error)));
              }
              if (state is ChatLoaded) {
                if (state.messages.isEmpty) {
                  return Center(
                    child: Text('No messages yet. Say hi! 👋',
                        style:
                            GoogleFonts.inter(color: AppColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: AppColors.surfaceVariant,
            child: Text(message.content,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic)),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onAccent,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isOwn ? AppColors.neonGreen : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isOwn ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isOwn ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isOwn)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(message.senderName ?? 'Unknown',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.neonGreen)),
                      ),
                    Text(message.content,
                        style: GoogleFonts.inter(
                            color: isOwn
                                ? AppColors.onAccent
                                : AppColors.neonGreen)),
                    const SizedBox(height: 4),
                    Text(
                        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isOwn
                                ? AppColors.onAccent.withValues(alpha: 0.6)
                                : AppColors.textSecondary)),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
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
                hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              style: GoogleFonts.inter(color: AppColors.neonGreen),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/messages/data/models/conversation_model.dart';
import '../../features/messages/data/models/message_model.dart';
import '../../features/messages/domain/repositories/message_repository.dart';
import '../../core/network/dio_client.dart';
import '../../features/messages/presentation/controllers/chat_cubit.dart';
import '../../features/messages/presentation/controllers/chat_state.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/pinned_messages_bar.dart';

/// Full-featured chat screen.
/// [ChatCubit] must be provided by the parent (MessagesScreen.openChat).
class MessageDetailScreen extends StatefulWidget {
  final ConversationModel conversation;

  const MessageDetailScreen({super.key, required this.conversation});

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final ScrollController _scroll = ScrollController();

  ConversationModel get _conv => widget.conversation;

  String get _myId {
    final s = context.read<AuthCubit>().state;
    return s is AuthSuccess ? s.user.id : '';
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        final target = _scroll.position.maxScrollExtent;
        if (animated) {
          _scroll.animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scroll.jumpTo(target);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F0F)
          : const Color(0xFFF0F4F8),
      appBar: _buildAppBar(isDark),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (ctx, state) {
          if (state.status == ChatStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          if (state.status == ChatStatus.success ||
              state.status == ChatStatus.sending) {
            _scrollToBottom();
          }
        },
        builder: (ctx, state) {
          return Column(
            children: [
              // Pinned messages bar
              PinnedMessagesBar(
                pinned: state.pinnedMessages,
                onUnpin: (id) => ctx.read<ChatCubit>().unpinMessage(id),
                onNavigate: (id) => _scrollToMessage(id, state.messages),
              ),
              // Message list
              Expanded(child: _buildMessageList(state)),
              // Input bar
              ChatInputBar(
                onSendText: (text) =>
                    ctx.read<ChatCubit>().sendText(text, _myId),
                onSendImage: (file) =>
                    ctx.read<ChatCubit>().sendImage(file, _myId),
                onSendFile: (file) =>
                    ctx.read<ChatCubit>().sendFile(file, _myId),
                onSendVoice: (file) =>
                    ctx.read<ChatCubit>().sendVoice(file, _myId),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final initial = _conv.userName.isNotEmpty
        ? _conv.userName[0].toUpperCase()
        : '?';
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0DA5FE).withOpacity(0.15),
                backgroundImage: _conv.userImage.isNotEmpty
                    ? NetworkImage(_getFullImageUrl(_conv.userImage))
                    : null,
                child: _conv.userImage.isEmpty
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFF0DA5FE),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              // Positioned(
              //   bottom: 1,
              //   right: 1,
              //   child: Container(
              //     width: 10,
              //     height: 10,
              //     decoration: BoxDecoration(
              //       color: Colors.green,
              //       shape: BoxShape.circle,
              //       border: Border.all(
              //         color: isDark
              //             ? const Color(0xFF1A1A1A)
              //             : Colors.white,
              //         width: 2,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _conv.userName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const Text(
              //   'Online',
              //   style: TextStyle(
              //     fontSize: 11,
              //     color: Colors.green,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
        const SizedBox(width: 4),
      ],
    );
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return '$fullUrl?v=$ts';
  }

  void _scrollToMessage(int messageId, List<MessageModel> messages) {
    final idx = messages.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      _scroll.animateTo(
        idx * 80.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildMessageList(ChatState state) {
    if (state.status == ChatStatus.loading && state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0DA5FE)),
      );
    }
    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0DA5FE).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: Color(0xFF0DA5FE),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Send the first message!',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: state.messages.length,
      itemBuilder: (_, i) {
        final msg = state.messages[i];
        final isMe = msg.isMine(_myId);

        // Date separator
        bool showDate = i == 0;
        if (i > 0) {
          final prev = state.messages[i - 1].sentAt;
          final curr = msg.sentAt;
          showDate =
              prev.day != curr.day ||
              prev.month != curr.month ||
              prev.year != curr.year;
        }

        // Show avatar only when sender changes
        final showAvatar =
            !isMe &&
            (i == state.messages.length - 1 ||
                state.messages[i + 1].isMine(_myId));

        return Column(
          children: [
            if (showDate) _dateSeparator(msg.sentAt),
            MessageBubble(
              message: msg,
              isMe: isMe,
              showAvatar: showAvatar,
              senderInitial: _conv.userName.isNotEmpty
                  ? _conv.userName[0].toUpperCase()
                  : '?',
              senderImage: _conv.userImage.isNotEmpty
                  ? _getFullImageUrl(_conv.userImage)
                  : null,
              onPin: () => context.read<ChatCubit>().pinMessage(msg.id),
              onUnpin: () => context.read<ChatCubit>().unpinMessage(msg.id),
            ),
          ],
        );
      },
    );
  }

  Widget _dateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat.yMMMMd().format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

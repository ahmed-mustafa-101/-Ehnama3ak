import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import '../../features/messages/data/models/conversation_model.dart';
import '../../features/messages/data/models/message_model.dart';
import '../../features/messages/presentation/controllers/message_cubit.dart';
import '../../features/messages/presentation/controllers/message_state.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';

class MessageDetailScreen extends StatefulWidget {
  final ConversationModel? conversation;
  final String? receiverId;
  final String? receiverName;
  final String? receiverProfileImage;

  const MessageDetailScreen({
    super.key,
    this.conversation,
    this.receiverId,
    this.receiverName,
    this.receiverProfileImage,
  }) : assert(conversation != null || (receiverId != null && receiverName != null),
            'Must provide either a conversation or receiver details');

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String get _displayName => widget.conversation?.senderName ?? widget.receiverName ?? '';
  String get _targetId => widget.conversation?.otherUserId ?? widget.receiverId ?? '';
  String? get _profileImg => widget.conversation?.profileImage ?? widget.receiverProfileImage;

  @override
  void initState() {
    super.initState();
    // Load message history on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageCubit>().loadMessages(_targetId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthCubit>().state;
    String? myId;
    if (authState is AuthSuccess) {
      myId = authState.user.id;
    }

    context.read<MessageCubit>().sendMessage(
          receiverId: _targetId,
          message: text,
          currentUserId: myId,
        );
    _messageController.clear();
  }

  String _formatMessageTime(DateTime date) {
    return DateFormat.jm().format(date); // e.g. 10:30 AM
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FB),
      appBar: _buildAppBar(context),
      body: BlocConsumer<MessageCubit, MessageState>(
        listener: (context, state) {
          if (state.status == MessageStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
          // Scroll to bottom when new messages arrive
          if (state.status == MessageStatus.success || state.status == MessageStatus.sending) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
        },
        builder: (context, state) {
          final authState = context.read<AuthCubit>().state;
          final myId = (authState is AuthSuccess) ? authState.user.id : '';

          return Column(
            children: [
              Expanded(
                child: state.status == MessageStatus.loadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessageList(state.messages, myId),
              ),
              _buildMessageInput(isDark, l10n),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: _profileImg != null ? NetworkImage(_profileImg!) : null,
                child: _profileImg == null ? Text(_displayName.isNotEmpty ? _displayName[0] : '?') : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Online',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildMessageList(List<MessageModel> messages, String myId) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No messages yet', style: TextStyle(color: Colors.grey)),
            const Text('Start a conversation now!', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.isMine(myId);
        
        // Show date separator if date changes
        bool showDate = false;
        if (index == 0) {
          showDate = true;
        } else {
          final prevDate = messages[index - 1].createdAt;
          if (prevDate.day != message.createdAt.day || 
              prevDate.month != message.createdAt.month || 
              prevDate.year != message.createdAt.year) {
            showDate = true;
          }
        }

        return Column(
          children: [
            if (showDate) _buildDateSeparator(message.createdAt),
            _buildChatBubble(message, isMe),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    String text = DateFormat.yMMMMd().format(date);
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      text = 'Today';
    } else if (date.day == now.day - 1 && date.month == now.month && date.year == now.year) {
      text = 'Yesterday';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF0DA5FE) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF262626) : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                fontSize: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.createdAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? Colors.blue : Colors.grey,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0DA5FE).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF0DA5FE)),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0DA5FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

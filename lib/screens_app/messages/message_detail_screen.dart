import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/messages/data/models/conversation_model.dart';
import '../../features/messages/presentation/controllers/message_cubit.dart';
import '../../features/messages/presentation/controllers/message_state.dart';

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

  String get _displayName => widget.conversation?.senderName ?? widget.receiverName ?? '';
  String get _targetId => widget.conversation?.otherUserId ?? widget.receiverId ?? '';
  String? get _profileImg => widget.conversation?.profileImage ?? widget.receiverProfileImage;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<MessageCubit>().sendMessage(
          receiverId: _targetId,
          message: text,
        );
    _messageController.clear();
    
    // If it's a new message (not from a conversation list), maybe show a success snackbar
    if (widget.conversation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: _profileImg != null ? NetworkImage(_profileImg!) : null,
              child: _profileImg == null ? Text(_displayName.isNotEmpty ? _displayName[0] : '?') : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_displayName,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: BlocConsumer<MessageCubit, MessageState>(
        listener: (context, state) {
          if (state.status == MessageStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Chat with $_displayName',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      if (widget.conversation != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Last message: ${widget.conversation!.lastMessage}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _buildMessageInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0DA5FE),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

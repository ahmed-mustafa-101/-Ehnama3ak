import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import '../../features/messages/presentation/controllers/message_cubit.dart';
import '../../features/messages/presentation/controllers/message_state.dart';
import 'message_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  final Function(int)? onDrawerItemSelected;
  const MessagesScreen({super.key, this.onDrawerItemSelected});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MessageCubit>().loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays < 1) {
      return DateFormat.jm().format(time);
    } else if (difference.inDays < 7) {
      return DateFormat('E').format(time);
    } else {
      return DateFormat('MM/dd').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n, isDark),
            _buildSearchBar(l10n, isDark),
            Expanded(
              child: BlocBuilder<MessageCubit, MessageState>(
                builder: (context, state) {
                  if (state.status == MessageStatus.loading && state.conversations.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state.status == MessageStatus.error && state.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('Failed to load messages', style: TextStyle(color: Colors.grey.shade600)),
                          TextButton(
                            onPressed: () => context.read<MessageCubit>().loadConversations(),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(l10n.noMessages, style: const TextStyle(color: Colors.grey, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Your chat list is empty', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context.read<MessageCubit>().loadConversations(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return _buildConversationItem(conversation, isDark);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                l10n.messagesTitle,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              BlocBuilder<MessageCubit, MessageState>(
                builder: (context, state) {
                  if (state.unreadCount > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0DA5FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        state.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262626) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF0DA5FE)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262626) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            icon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(dynamic conversation, bool isDark) {
    final hasUnread = conversation.unreadCount > 0;
    
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MessageDetailScreen(conversation: conversation)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnread ? const Color(0xFF0DA5FE) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: conversation.profileImage != null ? NetworkImage(conversation.profileImage!) : null,
                    child: conversation.profileImage == null ? Text(conversation.senderName.isNotEmpty ? conversation.senderName[0] : '?') : null,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF121212) : Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.senderName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread ? const Color(0xFF0DA5FE) : Colors.grey.shade500,
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: hasUnread ? (isDark ? Colors.white : Colors.black87) : Colors.grey.shade500,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0DA5FE),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

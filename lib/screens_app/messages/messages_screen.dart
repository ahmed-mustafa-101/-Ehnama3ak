import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<MessageCubit>().loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: BlocBuilder<MessageCubit, MessageState>(
                builder: (context, state) {
                  if (state.status == MessageStatus.loading && state.conversations.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == MessageStatus.error && state.conversations.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Error: ${state.errorMessage}'),
                      ElevatedButton(
                        onPressed: () => context.read<MessageCubit>().loadConversations(),
                        child: Text(l10n.retry),
                      ),
                    ]));
                  }
                  if (state.conversations.isEmpty) {
                    return Center(child: Text(l10n.noMessages));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => context.read<MessageCubit>().loadConversations(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: state.conversations.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: conversation.profileImage != null
                                ? NetworkImage(conversation.profileImage!) : null,
                            child: conversation.profileImage == null
                                ? Text(conversation.senderName.isNotEmpty ? conversation.senderName[0] : '?') : null,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(conversation.senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(_formatTime(conversation.lastMessageTime),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          subtitle: Row(children: [
                            Expanded(child: Text(conversation.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            if (conversation.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Color(0xFF0DA5FE), shape: BoxShape.circle),
                                child: Text(conversation.unreadCount.toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                          ]),
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => MessageDetailScreen(conversation: conversation))),
                        );
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

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(l10n.messagesTitle,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(width: 8),
          BlocBuilder<MessageCubit, MessageState>(
            builder: (context, state) {
              if (state.unreadCount > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  child: Text(state.unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays < 1) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

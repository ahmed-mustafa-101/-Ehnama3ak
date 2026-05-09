import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/messages/data/models/conversation_model.dart';
import '../../features/messages/domain/repositories/message_repository.dart';
import '../../features/messages/presentation/controllers/chat_cubit.dart';
import '../../features/messages/presentation/controllers/conversations_cubit.dart';
import '../../features/messages/presentation/controllers/conversations_state.dart';
import '../../features/messages/presentation/controllers/unread_cubit.dart';
import '../../features/messages/presentation/controllers/unread_state.dart';
import 'message_detail_screen.dart';
import 'widgets/conversation_tile.dart';

class MessagesScreen extends StatefulWidget {
  final Function(int)? onDrawerItemSelected;
  const MessagesScreen({super.key, this.onDrawerItemSelected});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  late final TabController _tabs;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _search.addListener(
        () => setState(() => _query = _search.text.toLowerCase()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationsCubit>().loadConversations();
      context.read<ConversationsCubit>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _tabs.dispose();
    super.dispose();
  }

  List<ConversationModel> _filter(List<ConversationModel> list) {
    if (_query.isEmpty) return list;
    return list
        .where((c) =>
            c.userName.toLowerCase().contains(_query) ||
            c.lastMessage.toLowerCase().contains(_query))
        .toList();
  }

  // ── Navigation ──────────────────────────────────────────────────────────
  void _openChat(ConversationModel conversation) {
    final repo = context.read<MessageRepository>();
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChatCubit(
              repo: repo,
              conversationId: conversation.conversationId,
              receiverId: conversation.userId,
            )..loadMessages(),
            child: MessageDetailScreen(conversation: conversation),
          ),
        ))
        .then((_) {
      if (!mounted) return;
      context.read<ConversationsCubit>().loadConversations();
      context.read<UnreadCubit>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildSearchBar(isDark),
            _buildTabBar(isDark),
            Expanded(
              child: BlocBuilder<ConversationsCubit, ConversationsState>(
                builder: (context, state) => TabBarView(
                  controller: _tabs,
                  children: [
                    _buildList(state, state.conversations, isDark),
                    _buildList(
                      state,
                      state.favorites,
                      isDark,
                      emptyMsg: 'No favorites yet',
                      emptySubMsg:
                          'Star a conversation to see it here',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5),
              ),
              BlocBuilder<UnreadCubit, UnreadState>(
                builder: (_, s) => s.count > 0
                    ? Text(
                        '${s.count} unread',
                        style: const TextStyle(
                            color: Color(0xFF0DA5FE), fontSize: 13),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const Spacer(),
          _circleBtn(
            icon: Icons.refresh_rounded,
            onTap: () {
              context.read<ConversationsCubit>().loadConversations();
              context.read<UnreadCubit>().refresh();
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262626) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child:
            Icon(icon, color: const Color(0xFF0DA5FE), size: 20),
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Search conversations…',
            hintStyle:
                TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.grey.shade400, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────
  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabs,
          indicator: BoxDecoration(
            color: const Color(0xFF0DA5FE),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: '⭐  Favorites'),
          ],
        ),
      ),
    );
  }

  // ── Conversation list ────────────────────────────────────────────────────
  Widget _buildList(
    ConversationsState state,
    List<ConversationModel> raw,
    bool isDark, {
    String emptyMsg = 'No conversations yet',
    String emptySubMsg =
        'Messages from your doctor/patient will appear here',
  }) {
    if (state.status == ConversationsStatus.loading && raw.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(
              color: Color(0xFF0DA5FE)));
    }
    if (state.status == ConversationsStatus.error && raw.isEmpty) {
      return _errorState(state.errorMessage ?? 'Something went wrong');
    }
    final items = _filter(raw);
    if (items.isEmpty) {
      return _emptyState(emptyMsg, emptySubMsg);
    }
    return RefreshIndicator(
      onRefresh: () async {
        final convCubit = context.read<ConversationsCubit>();
        final unreadCubit = context.read<UnreadCubit>();
        await convCubit.loadConversations();
        await unreadCubit.refresh();
      },
      color: const Color(0xFF0DA5FE),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          indent: 78,
          endIndent: 20,
          height: 1,
          color: isDark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
        ),
        itemBuilder: (_, i) {
          final c = items[i];
          return ConversationTile(
            conversation: c,
            onTap: () => _openChat(c),
            onToggleFavorite: () => context
                .read<ConversationsCubit>()
                .toggleFavorite(c.conversationId),
          );
        },
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────
  Widget _emptyState(String msg, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0DA5FE).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_outlined,
                size: 56, color: Color(0xFF0DA5FE)),
          ),
          const SizedBox(height: 20),
          Text(msg,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(sub,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 13),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  // ── Error state ──────────────────────────────────────────────────────────
  Widget _errorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 56, color: Colors.red.withOpacity(0.6)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(message,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0DA5FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () =>
                context.read<ConversationsCubit>().loadConversations(),
          ),
        ],
      ),
    );
  }
}

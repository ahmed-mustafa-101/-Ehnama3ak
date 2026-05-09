import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../features/messages/data/models/conversation_model.dart';
import '../../../core/network/dio_client.dart';

/// A single row in the conversations list (Messenger/WhatsApp style).
class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onToggleFavorite,
  });

  static const _blue = Color(0xFF0DA5FE);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUnread = conversation.unreadCount > 0;
    final initial = conversation.userName.isNotEmpty
        ? conversation.userName[0].toUpperCase()
        : '?';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasUnread
                        ? const LinearGradient(
                            colors: [_blue, Color(0xFF0077C2)],
                          )
                        : null,
                    border: hasUnread
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: _blue.withOpacity(0.15),
                    backgroundImage: conversation.userImage.isNotEmpty
                        ? NetworkImage(_getFullImageUrl(conversation.userImage))
                        : null,
                    child: conversation.userImage.isEmpty
                        ? Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _blue,
                            ),
                          )
                        : null,
                  ),
                ),
                // Online dot
                // Positioned(
                //   bottom: 3,
                //   right: 3,
                //   child: Container(
                //     width: 12,
                //     height: 12,
                //     decoration: BoxDecoration(
                //       color: Colors.green,
                //       shape: BoxShape.circle,
                //       border: Border.all(
                //         color: isDark ? const Color(0xFF121212) : Colors.white,
                //         width: 2,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          conversation.userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUnread ? _blue : Colors.grey.shade500,
                          fontWeight: hasUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage.isEmpty
                              ? 'Start a conversation'
                              : conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? (isDark ? Colors.white70 : Colors.black87)
                                : Colors.grey.shade500,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: _blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: onToggleFavorite,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            conversation.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 20,
                            color: conversation.isFavorite
                                ? Colors.amber
                                : Colors.grey.shade400,
                          ),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 24) return DateFormat.jm().format(time);
    if (diff.inDays < 7) return DateFormat('EEE').format(time);
    return DateFormat('MM/dd').format(time);
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    // Add cache buster to refresh image if it changed on server
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return '$fullUrl?v=$ts';
  }
}

import 'package:flutter/material.dart';
import 'package:ehnama3ak/features/notifications/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    Color cardColor;
    if (isDark) {
      cardColor = isUnread ? const Color(0xFF1A2A3A) : const Color(0xFF1E1E1E);
    } else {
      cardColor = isUnread ? const Color(0xFFEBF6FF) : const Color(0xFFF5F9FD);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isUnread
            ? Border.all(color: const Color(0xFF0DA5FE).withOpacity(0.4), width: 1)
            : null,
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bell icon with unread indicator
              Stack(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0DA5FE).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: const Color(0xFF0DA5FE),
                      size: 24,
                    ),
                  ),
                  if (isUnread)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0DA5FE),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF2C3E50),
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : Colors.blueGrey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Relative time — bottom right
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              timeago.format(notification.createdAt, locale: 'en_short'),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

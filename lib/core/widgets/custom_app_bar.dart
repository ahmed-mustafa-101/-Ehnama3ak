import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/notifications/presentation/cubit/notification_state.dart';
import '../../screens_app/notifications/notifications_screen.dart';

import '../../features/messages/presentation/controllers/message_cubit.dart';
import '../../features/messages/presentation/controllers/message_state.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMessageTap;

  const CustomAppBar({super.key, this.onNotificationTap, this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Logo
          Image.asset('assets/images/name.png', width: 150),
          const Spacer(),

          // Notification icon with live unread badge
          BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
            builder: (context, state) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      if (onNotificationTap != null) {
                        onNotificationTap!();
                      } else {
                        if (context
                                .findAncestorWidgetOfExactType<
                                  NotificationsScreen
                                >() !=
                            null) {
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.notifications_rounded,
                      color: Color(0xff0DA5FE),
                      size: 35,
                    ),
                  ),
                  if (state.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          state.unreadCount > 99
                              ? '99+'
                              : '${state.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    // Small static dot when no precise count (initial state)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(width: 4),

          // Messenger icon with unread badge
          BlocBuilder<MessageCubit, MessageState>(
            buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
            builder: (context, state) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Image.asset(
                        'assets/images/messageicon.png',
                        width: 28,
                        height: 28,
                      ),
                      onPressed: () {
                        if (onMessageTap != null) {
                          onMessageTap!();
                        }
                      },
                    ),
                  ),
                  if (state.unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          state.unreadCount > 99
                              ? '99+'
                              : '${state.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 30, color: Color(0xff0DA5FE)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}

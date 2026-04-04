import 'package:ehnama3ak/core/widgets/app_icon_back.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';
import '../../features/notifications/presentation/cubit/notification_state.dart';
import 'widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  final Function(int)? onDrawerItemSelected;

  const NotificationsScreen({super.key, this.onDrawerItemSelected});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<NotificationCubit>();
      // Load notifications and mark all as read when screen opens
      cubit.loadNotifications().then((_) => cubit.markAllAsRead());
    });
  }

  Future<void> _handleClearAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.clearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.clearAll,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<NotificationCubit>().clearAllNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null &&
              state.status != NotificationStatus.loading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.read<NotificationCubit>().clearError();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state, isDark),
                Expanded(child: _buildBody(context, state, isDark)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationState state,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          AppIconBack(top: 5, left: 0),
          const Spacer(),
          Text(
            AppLocalizations.of(context).notificationsTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2C3E50),
            ),
          ),
          // Unread badge
          if (state.unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0DA5FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${state.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (state.notifications.isNotEmpty &&
              state.status != NotificationStatus.loading)
            GestureDetector(
              onTap: () => _handleClearAll(context),
              child: Text(
                AppLocalizations.of(context).clearAll,
                style: TextStyle(
                  color: Color(0xFF0DA5FE),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationState state,
    bool isDark,
  ) {
    if (state.status == NotificationStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0DA5FE)),
      );
    }

    if (state.status == NotificationStatus.error &&
        state.notifications.isEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        icon: Icons.wifi_off_rounded,
        title: AppLocalizations.of(context).failedToLoadNotifications,
        subtitle: state.errorMessage ?? AppLocalizations.of(context).checkConnection,
        showRetry: true,
        onRetry: () => context.read<NotificationCubit>().loadNotifications(),
      );
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        icon: Icons.notifications_off_outlined,
        title: AppLocalizations.of(context).noNotifications,
        subtitle: AppLocalizations.of(context).noNotificationsSubtitle,
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF0DA5FE),
      onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: state.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return NotificationCard(notification: state.notifications[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRetry = false,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: isDark ? Colors.white24 : Colors.blueGrey.shade200,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : const Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.blueGrey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0DA5FE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

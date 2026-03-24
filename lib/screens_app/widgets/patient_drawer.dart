import 'package:ehnama3ak/core/widgets/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/user_role.dart';
import '../../core/storage/pref_manager.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import 'doctor_drawer.dart';
import '../../core/widgets/theme/theme_notifier.dart';
import '../../features/settings/presentation/controllers/settings_cubit.dart';
import '../../features/settings/presentation/controllers/settings_state.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole>(
      future: PrefManager.getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;

        if (role == UserRole.doctor) {
          return DoctorDrawer(selectedIndex: selectedIndex, onSelect: onSelect);
        }

        // Default Patient Drawer
        return Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildPatientHeader(context),
                const Divider(height: 30),
                _item(context, Icons.home_rounded, 'Home', 0),
                _item(context, Icons.autorenew_rounded, 'My Progress', 1),
                _item(context, Icons.people_alt_outlined, 'Therapists', 2),
                _item(context, Icons.public, 'Resources', 3),
                _item(context, Icons.settings_outlined, 'Settings', 4),
                _item(
                  context,
                  Icons.dark_mode_outlined,
                  'Night Mood',
                  -1,
                  onTap: () {
                    ThemeNotifier.toggleTheme();
                    Navigator.pop(context);
                  },
                ),
                _item(context, Icons.help_outline, 'Help', 5),
                const Spacer(),

                _item(
                  context,
                  Icons.logout,
                  'Log Out',
                  7,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => LogoutDialog(
                        onLogout: () async {
                          Navigator.pop(context);
                          if (!context.mounted) return;
                          context.read<AuthCubit>().logout();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientHeader(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final user = state.userSettings;

        // Trigger fetch if we don't have user info yet
        if (user == null && state.status == SettingsStatus.initial) {
          context.read<SettingsCubit>().fetchSettings();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF0DA5FE).withValues(alpha: 0.1),
                backgroundImage: (user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty)
                    ? NetworkImage(user.profileImageUrl!)
                    : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (user?.name != null && user!.name.isNotEmpty) 
                          ? user.name 
                          : 'Loading...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    int index, {
    bool logout = false,
    VoidCallback? onTap,
  }) {
    final bool selected = selectedIndex == index;
    final Color itemColor = logout
        ? Colors.red
        : (selected
              ? const Color(0xFF1E88E5)
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87));

    return ListTile(
      leading: Icon(icon, size: 30, color: itemColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: logout || selected ? FontWeight.w600 : FontWeight.w400,
          color: itemColor,
        ),
      ),
      onTap: onTap ?? () => onSelect(index),
    );
  }
}

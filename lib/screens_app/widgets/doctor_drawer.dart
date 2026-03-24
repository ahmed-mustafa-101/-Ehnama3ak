import 'package:ehnama3ak/core/widgets/logout_dialog.dart';
import 'package:ehnama3ak/core/widgets/registered_doctor_profile_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../core/widgets/theme/theme_notifier.dart';

class DoctorDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const DoctorDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                children: [
                  _buildItem(
                    context,
                    0,
                    Icons.home_rounded,
                    'Home',
                    selectedIndex == 0,
                  ),
                  _buildItem(
                    context,
                    1,
                    Icons.chat_bubble_outline_rounded,
                    'Sessions',
                    selectedIndex == 1,
                  ),
                  _buildItem(
                    context,
                    2,
                    Icons.people_outline_rounded,
                    'Patients',
                    selectedIndex == 2,
                  ),
                  _buildItem(
                    context,
                    3,
                    Icons.trending_up_rounded,
                    'Reports',
                    selectedIndex == 3,
                  ),
                  _buildItem(
                    context,
                    4,
                    Icons.settings_outlined,
                    'Settings',
                    selectedIndex == 4,
                  ),

                  // Night Mood Toggle
                  _buildItem(
                    context,
                    -2,
                    Icons.dark_mode_outlined,
                    'Night Mood',
                    false,
                    onTap: () {
                      ThemeNotifier.toggleTheme();
                      Navigator.pop(context);
                    },
                  ),

                  _buildItem(
                    context,
                    5,
                    Icons.help_outline_rounded,
                    'Help',
                    selectedIndex == 5,
                  ),
                ],
              ),
            ),
            _buildItem(
              context,
              7,
              Icons.logout,
              'Log Out',
              false,
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
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (current is AuthSuccess) {
          if (previous is AuthSuccess) return previous.user != current.user;
          return true;
        }
        return previous is AuthSuccess;
      },
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0DA5FE),
                    width: 1.5,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: RegisteredDoctorProfileTexts(
                  user: user,
                  nameStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  specializationStyle:
                      const TextStyle(color: Colors.grey, fontSize: 13),
                  yearsStyle:
                      const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
    bool isSelected, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final Color color = isLogout
        ? Colors.black
        : (isSelected ? const Color(0xFF0DA5FE) : Colors.black);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: onTap ?? () => onSelect(index),
    );
  }
}

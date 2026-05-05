import 'package:ehnama3ak/core/widgets/logout_dialog.dart';
import 'package:ehnama3ak/core/widgets/registered_doctor_profile_texts.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_state.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
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
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
                    AppLocalizations.of(context).home,
                    selectedIndex == 0,
                  ),
                  _buildItem(
                    context,
                    1,
                    Icons.chat_bubble_outline_rounded,
                    AppLocalizations.of(context).sessions,
                    selectedIndex == 1,
                  ),
                  _buildItem(
                    context,
                    2,
                    Icons.people_outline_rounded,
                    AppLocalizations.of(context).patients,
                    selectedIndex == 2,
                  ),
                  _buildItem(
                    context,
                    3,
                    Icons.trending_up_rounded,
                    AppLocalizations.of(context).reports,
                    selectedIndex == 3,
                  ),
                  _buildItem(
                    context,
                    4,
                    Icons.settings_outlined,
                    AppLocalizations.of(context).settings,
                    selectedIndex == 4,
                  ),
                  _buildItem(
                    context,
                    -2,
                    Icons.dark_mode_outlined,
                    AppLocalizations.of(context).nightMood,
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
                    AppLocalizations.of(context).help,
                    selectedIndex == 5,
                  ),
                ],
              ),
            ),
            _buildItem(
              context,
              7,
              Icons.logout,
              AppLocalizations.of(context).logOut,
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

    return BlocBuilder<DoctorDashboardCubit, DoctorDashboardState>(
      builder: (context, state) {
        if (state is DoctorDashboardSuccess) {
          final header = state.header;
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
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: header.imageUrl.isNotEmpty
                        ? NetworkImage(_getFullImageUrl(header.imageUrl))
                        : const AssetImage('assets/images/user_avatar.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        header.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        header.specialization,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${header.experienceYears} Years Exp',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Fallback or loading state
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
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: const AssetImage('assets/images/user_avatar.png'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
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
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = isSelected
        ? const Color(0xFF0DA5FE)
        : (isDark ? Colors.white : Colors.black);

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
      selected: isSelected,
      selectedTileColor: isDark
          ? Colors.white.withOpacity(0.05)
          : const Color(0xFF0DA5FE).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onTap: onTap ?? () => onSelect(index),
    );
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    // Cache-busting
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return '$fullUrl?v=$ts';
  }
}

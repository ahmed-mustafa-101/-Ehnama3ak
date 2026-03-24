import 'package:ehnama3ak/core/widgets/app_button.dart';
import 'package:ehnama3ak/core/widgets/app_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/logout_dialog.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import 'widgets/stat_cardprofile.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  static const Color primaryColor = Color(0xFF0DA5FE);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 90,
              backgroundImage: AssetImage('assets/images/image_patient.png'),
            ),

            const SizedBox(height: 14),

            // ===== NAME + EDIT PROFILE (SAME ROW) =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ===== NAME & EMAIL =====
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ahmed Awad!!!!!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ahmedawad@gmail.com',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // ===== EDIT PROFILE BUTTON =====
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 14,
                //     vertical: 8,
                //   ),
                //   decoration: BoxDecoration(
                //     color: primaryColor,
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Row(
                //     children: const [
                //       Icon(Icons.edit, size: 14, color: Colors.white),
                //       SizedBox(width: 6),
                //       Text(
                //         'Edit Profile',
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 13,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: AppButton(
                    label: 'Edit Profile',
                    onPressed: () {},
                    icon: Icons.edit,
                    iconSize: 15,
                    width: 150,
                    height: 40,
                    radius: 20,
                    textStyle: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatCard(title: 'Sessions', value: '12'),
                StatCard(title: 'Exercises', value: '24'),
                StatCard(title: 'Days', value: '18'),
              ],
            ),

            const SizedBox(height: 30),

            AppTile(
              icon: Icons.settings,
              title: 'Account Settings',
              onTap: () {},
            ),
            AppTile(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {},
            ),
            AppTile(icon: Icons.language, title: 'Language', onTap: () {}),
            AppTile(
              icon: Icons.bookmark_outline,
              title: 'Saved Resources',
              onTap: () {},
            ),
            AppTile(
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LogoutDialog(
        onLogout: () async {
          Navigator.pop(context);
          if (!context.mounted) return;
          context.read<AuthCubit>().logout();
        },
      ),
    );
  }
}

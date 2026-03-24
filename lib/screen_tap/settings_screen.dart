import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/settings/presentation/controllers/settings_cubit.dart';
import '../features/settings/presentation/controllers/settings_state.dart';
import '../features/auth/presentation/controllers/auth_cubit.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/logout_dialog.dart';
import '../core/widgets/app_tile.dart';
import 'section_title.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
            context.read<SettingsCubit>().resetStatus();
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading && state.userSettings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.userSettings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // ===== Profile Card =====
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: user?.profileImageUrl != null
                            ? NetworkImage(user!.profileImageUrl!)
                            : const AssetImage('assets/images/image_patient.png') as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (user?.name != null && user!.name.isNotEmpty) 
                                  ? user.name 
                                  : '...',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (user?.email != null && user!.email.isNotEmpty)
                                  ? user.email
                                  : '...',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppButton(
                        label: 'Edit',
                        onPressed: () => _showEditProfileDialog(context, user?.name ?? '', user?.email ?? ''),
                        width: 68,
                        height: 30,
                        radius: 6,
                        textStyle: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===== General =====
                const SectionTitle('General'),

                AppTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () {},
                ),
                AppTile(
                  icon: Icons.language,
                  title: 'Language',
                  trailingText: 'English',
                  onTap: () {},
                ),
                AppTile(
                  icon: Icons.security,
                  title: 'Security',
                  onTap: () => _showChangePasswordDialog(context),
                ),
                AppTile(icon: Icons.share, title: 'Share App', onTap: () {}),

                const SizedBox(height: 20),

                // ===== Support =====
                const SectionTitle('Support'),

                AppTile(
                  icon: Icons.help_outline,
                  title: 'Support Center',
                  onTap: () => _showSupportInfo(context),
                ),
                AppTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _showPrivacyPolicy(context),
                ),

                const SizedBox(height: 10),

                // ===== Logout =====
                AppTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  isLogout: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String name, String email) {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(diagContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsCubit>().updateProfile(
                name: nameController.text,
                email: emailController.text,
              );
              Navigator.pop(diagContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(diagContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsCubit>().changePassword(
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
              );
              Navigator.pop(diagContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    context.read<SettingsCubit>().fetchPrivacyPolicy();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Privacy Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: state.status == SettingsStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(child: Text(state.privacyPolicy?.content ?? 'No content')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSupportInfo(BuildContext context) {
    context.read<SettingsCubit>().fetchSupportInfo();
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Support Center', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                if (state.status == SettingsStatus.loading)
                  const CircularProgressIndicator()
                else if (state.supportInfo != null) ...[
                  ListTile(leading: const Icon(Icons.email), title: Text(state.supportInfo!.email)),
                  ListTile(leading: const Icon(Icons.phone), title: Text(state.supportInfo!.phone)),
                  if (state.supportInfo!.description != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(state.supportInfo!.description!),
                    ),
                ],
              ],
            ),
          );
        },
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
          context.read<AuthCubit>().logout();
        },
      ),
    );
  }
}

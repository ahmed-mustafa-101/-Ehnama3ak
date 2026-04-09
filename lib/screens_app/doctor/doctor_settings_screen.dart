import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_cubit.dart';
import '../../core/widgets/logout_dialog.dart';
import '../../core/widgets/registered_doctor_profile_texts.dart';
import '../../features/auth/data/models/auth_model.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../core/network/dio_client.dart';
import '../notifications/notifications_screen.dart';
import '../../features/settings/presentation/controllers/settings_cubit.dart';
import '../../features/settings/presentation/controllers/settings_state.dart';

class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<SettingsCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildDoctorHeader(context, isDark, l10n),
              const SizedBox(height: 20),
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (prev, curr) {
                  if (curr is AuthSuccess) {
                    if (prev is AuthSuccess) return prev.user != curr.user;
                    return true;
                  }
                  return prev is AuthSuccess;
                },
                builder: (context, state) {
                  final user = state is AuthSuccess ? state.user : null;
                  return SizedBox(
                    width: 220,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showEditProfileDialog(context, user, l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0DA5FE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.editProfile,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              _buildSettingItem(
                context,
                Icons.notifications_active_outlined,
                l10n.notifications,
                hasDivider: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              _buildSettingItem(
                context,
                Icons.translate_rounded,
                l10n.language,
                trailingText: isArabic ? 'العربية' : 'English',
                hasDivider: true,
                onTap: () => _showLanguageSheet(context, l10n),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context,
                Icons.verified_user_outlined,
                l10n.security,
                onTap: () => _showChangePasswordDialog(context, l10n),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context,
                Icons.share_outlined,
                l10n.shareApp,
                onTap: () {},
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    l10n.support,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              _buildSettingItem(
                context,
                Icons.help_center_outlined,
                l10n.supportCenter,
                hasDivider: true,
                onTap: () => _showSupportInfo(context, l10n),
              ),
              _buildSettingItem(
                context,
                Icons.lock_outline_rounded,
                l10n.privacyPolicy,
                onTap: () => _showPrivacyPolicy(context, l10n),
              ),
              const SizedBox(height: 20),
              _buildSettingItem(
                context,
                Icons.logout_rounded,
                l10n.logOut,
                isLogout: true,
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSheet(BuildContext context, AppLocalizations l10n) {
    final localeCubit = context.read<LocaleCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocBuilder<LocaleCubit, Locale>(
        bloc: localeCubit,
        builder: (ctx, currentLocale) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _LanguageTile(
                  label: 'English',
                  flag: '🇺🇸',
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () {
                    localeCubit.setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
                _LanguageTile(
                  label: 'العربية',
                  flag: '🇸🇦',
                  isSelected: currentLocale.languageCode == 'ar',
                  onTap: () {
                    localeCubit.setLocale(const Locale('ar'));
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return '$fullUrl?v=$ts';
  }

  Widget _buildDoctorHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, curr) {
        if (curr is AuthSuccess) {
          if (prev is AuthSuccess) return prev.user != curr.user;
          return true;
        }
        return prev is AuthSuccess;
      },
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        return Column(
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  if (!context.mounted) return;
                  context.read<AuthCubit>().updateProfileImage(image.path);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.uploadingImage)));
                }
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF0DA5FE), Colors.lightBlueAccent],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          (user?.profileImageUrl != null &&
                              user!.profileImageUrl!.isNotEmpty)
                          ? NetworkImage(
                              _getFullImageUrl(user.profileImageUrl!),
                            )
                          : const AssetImage('assets/images/user_avatar.png')
                                as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0DA5FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            RegisteredDoctorProfileTexts(
              user: user,
              crossAxisAlignment: CrossAxisAlignment.center,
              textAlign: TextAlign.center,
              nameStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              specializationStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              yearsStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(
                    10,
                    (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: index < 7
                          ? const Color(0xFF0DA5FE)
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.green,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AppLocalizations.of(context).available,
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title, {
    String? trailingText,
    bool hasDivider = false,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!hasDivider)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              icon,
              color: isLogout ? Colors.red : const Color(0xFF0DA5FE),
              size: 28,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLogout
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: onTap ?? () {},
          ),
          if (hasDivider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    AuthModel? user,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController(
      text: user?.displayNameLine ?? '',
    );
    final specController = TextEditingController(
      text: (user?.specialization ?? '').trim(),
    );
    final yearsController = TextEditingController(
      text: user?.yearsOfExperience?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: Text(l10n.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.fullName),
              ),
              TextField(
                controller: specController,
                decoration: const InputDecoration(labelText: 'Specialization'),
                readOnly: true,
              ),
              TextField(
                controller: yearsController,
                decoration: const InputDecoration(
                  labelText: 'Years of experience',
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Profile data comes from your account.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(diagContext);
              final settingsCubit = context.read<SettingsCubit>();
              final authCubit = context.read<AuthCubit>();
              await settingsCubit.updateProfile(
                name: newName,
                email: user?.email ?? '',
              );
              if (context.mounted) await authCubit.reloadUser();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppLocalizations l10n) {
    final cpCtrl = TextEditingController();
    final npCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cpCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
            ),
            TextField(
              controller: npCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.newPassword),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(diagContext),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (cpCtrl.text.isEmpty || npCtrl.text.isEmpty) return;
                    context.read<SettingsCubit>().changePassword(
                      currentPassword: cpCtrl.text.trim(),
                      newPassword: npCtrl.text.trim(),
                    );
                    Navigator.pop(diagContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0DA5FE),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.update),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              l10n.privacyPolicy,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const Expanded(
              child: SingleChildScrollView(
                child: Text('Your privacy policy content here...'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportInfo(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.supportCenter,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('am6888122@gmail.com.com'),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('+201099876619'),
            ),
          ],
        ),
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

class _LanguageTile extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0DA5FE).withValues(alpha: 0.12)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF0DA5FE), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF0DA5FE)
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0DA5FE)),
          ],
        ),
      ),
    );
  }
}

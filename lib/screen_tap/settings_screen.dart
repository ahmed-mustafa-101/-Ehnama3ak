import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/locale_cubit.dart';
import '../features/settings/presentation/controllers/settings_cubit.dart';
import '../features/settings/presentation/controllers/settings_state.dart';
import '../features/auth/presentation/controllers/auth_cubit.dart';
import '../core/widgets/logout_dialog.dart';
import '../core/widgets/app_tile.dart';
import '../core/network/dio_client.dart';
import '../screens_app/notifications/notifications_screen.dart';
import 'section_title.dart';
import 'package:share_plus/share_plus.dart';

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

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return '$fullUrl?v=$ts';
  }

  void _showLanguageSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<SettingsCubit, SettingsState>(
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
          } else if (state.status == SettingsStatus.success) {
            if (state.isPasswordChanging) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.passwordUpdatedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            }
            context.read<SettingsCubit>().resetStatus();
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading &&
              state.userSettings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.userSettings;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  l10n.settings,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: state.isUpdating
                            ? null
                            : () async {
                                final picker = ImagePicker();
                                final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null && context.mounted) {
                                  await context
                                      .read<SettingsCubit>()
                                      .uploadAvatar(image.path);
                                }
                              },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage:
                              (user?.profileImageUrl != null &&
                                  user!.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(
                                  _getFullImageUrl(user.profileImageUrl!),
                                )
                              : const AssetImage(
                                      'assets/images/user_avatar.png',
                                    )
                                    as ImageProvider,
                        ),
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
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.general),
                AppTile(
                  icon: Icons.notifications_none,
                  title: l10n.notifications,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                AppTile(
                  icon: Icons.language,
                  title: l10n.language,
                  trailingText: isArabic ? 'العربية' : 'English',
                  onTap: () => _showLanguageSheet(context),
                ),
                AppTile(
                  icon: Icons.security,
                  title: l10n.security,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                AppTile(
                  icon: Icons.share,
                  title: l10n.shareApp,
                  onTap: () {
                    Share.share(
                      '${l10n.shareAppContent ?? 'Check out Ehnama3ak App!'} \n https://play.google.com/store/apps/details?id=com.ehnama3ak.app',
                    );
                  },
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.support),
                AppTile(
                  icon: Icons.help_outline,
                  title: l10n.supportCenter,
                  onTap: () => _showSupportInfo(context),
                ),
                AppTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacyPolicy,
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const SizedBox(height: 10),
                AppTile(
                  icon: Icons.logout,
                  title: l10n.logOut,
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

  void _showChangePasswordDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cpCtrl = TextEditingController();
    final npCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (diagContext) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: BlocListener<SettingsCubit, SettingsState>(
          listener: (context, state) {
            if (state.status == SettingsStatus.success &&
                state.isPasswordChanging) {
              Navigator.pop(diagContext);
            }
          },
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return AlertDialog(
                title: Text(l10n.changePassword),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: cpCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.currentPassword,
                      ),
                      obscureText: true,
                    ),
                    TextField(
                      controller: npCtrl,
                      decoration: InputDecoration(labelText: l10n.newPassword),
                      obscureText: true,
                    ),
                  ],
                ),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isPasswordChanging
                              ? null
                              : () => Navigator.pop(diagContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0DA5FE),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.isPasswordChanging
                              ? null
                              : () {
                                  if (cpCtrl.text.isEmpty ||
                                      npCtrl.text.isEmpty)
                                    return;
                                  context.read<SettingsCubit>().changePassword(
                                    currentPassword: cpCtrl.text.trim(),
                                    newPassword: npCtrl.text.trim(),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0DA5FE),
                            foregroundColor: Colors.white,
                          ),
                          child: state.isPasswordChanging
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.update),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.read<SettingsCubit>().fetchPrivacyPolicy();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                l10n.privacyPolicy,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              Expanded(
                child: state.status == SettingsStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(state.privacyPolicy?.content ?? ''),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.read<SettingsCubit>().fetchSupportInfo();
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.supportCenter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              if (state.status == SettingsStatus.loading)
                const CircularProgressIndicator()
              else if (state.supportInfo != null) ...[
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(state.supportInfo!.email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(state.supportInfo!.phone),
                ),
                if (state.supportInfo!.description != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(state.supportInfo!.description!),
                  ),
              ],
            ],
          ),
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

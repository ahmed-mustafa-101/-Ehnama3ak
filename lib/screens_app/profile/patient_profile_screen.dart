// import 'dart:io';
import 'package:ehnama3ak/core/network/dio_client.dart';
import 'package:ehnama3ak/core/widgets/app_tile.dart';
import 'package:ehnama3ak/core/widgets/custom_app_button.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/screen_tap/settings_screen.dart';
import 'package:ehnama3ak/screens_app/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/logout_dialog.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/settings/presentation/controllers/settings_cubit.dart';
import 'widgets/stat_cardprofile.dart';
import 'package:ehnama3ak/screens_app/profile/presentation/cubit/profile_cubit.dart';
import 'package:ehnama3ak/screens_app/profile/presentation/cubit/profile_state.dart';
import 'package:ehnama3ak/screens_app/profile/models/profile_model.dart';
import 'package:ehnama3ak/screens_app/profile/saved_resources_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  static const Color primaryColor = Color(0xFF0DA5FE);

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    // Fix backslashes if they come from server
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    // Cache-busting: force Flutter to reload image after avatar update
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return '$fullUrl?v=$ts';
  }

  void _showEditProfileDialog(ProfileModel profile) {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: profile.fullName);
    final ageCtrl = TextEditingController(text: profile.age.toString());
    String selectedGender = profile.gender.isNotEmpty ? profile.gender : 'Male';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.editProfile),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.age,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: ['Male', 'Female'].contains(selectedGender)
                          ? selectedGender
                          : 'Male',
                      decoration: InputDecoration(
                        labelText: l10n.gender,
                        border: const OutlineInputBorder(),
                      ),
                      items: ['Male', 'Female']
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedGender = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final cubit = context.read<ProfileCubit>();
                    final settingsCubit = context.read<SettingsCubit>();
                    final age = int.tryParse(ageCtrl.text) ?? 0;
                    
                    Navigator.pop(context);
                    
                    await cubit.updateProfile(
                      fullName: nameCtrl.text,
                      age: age,
                      gender: selectedGender,
                    );
                    
                    if (context.mounted) {
                      settingsCubit.fetchSettings();
                    }
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSavedResources() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedResourcesScreen()),
    ).then((_) {
      // Refresh profile data automatically when returning back
      context.read<ProfileCubit>().loadProfile();
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is UpdateProfileLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.updatingProfile),
              duration: const Duration(milliseconds: 500),
            ),
          );
        } else if (state is UpdateProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) =>
            current is ProfileLoading ||
            current is ProfileSuccess ||
            current is ProfileError,
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: Text(l10n.tryAgain),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileSuccess) {
            final profile = state.profile;
            return RefreshIndicator(
              onRefresh: () async => context.read<ProfileCubit>().loadProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profile.avatarUrl.isNotEmpty
                              ? NetworkImage(
                                  _getFullImageUrl(profile.avatarUrl),
                                )
                              : const AssetImage(
                                      'assets/images/user_avatar.png',
                                    )
                                    as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.uploadingImage)),
                                );
                                await context
                                    .read<ProfileCubit>()
                                    .updateProfileImage(image.path);
                                if (!context.mounted) return;
                                context.read<SettingsCubit>().fetchSettings();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName.isNotEmpty
                                    ? profile.fullName
                                    : l10n.noName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.email.isNotEmpty
                                    ? profile.email
                                    : l10n.noEmail,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomSmallButton(
                          label: l10n.editProfile,
                          icon: Icons.edit,
                          onPressed: () => _showEditProfileDialog(profile),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        StatCard(
                          title: l10n.sessionsLabel,
                          value: profile.sessionsCompleted.toString(),
                        ),
                        StatCard(
                          title: l10n.exercisesLabel,
                          value: profile.exercisesCompleted.toString(),
                        ),
                        StatCard(
                          title: l10n.daysLabel,
                          value: profile.activeDays.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    AppTile(
                      icon: Icons.settings,
                      title: l10n.accountSettings,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    AppTile(
                      icon: Icons.notifications,
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    AppTile(
                      icon: Icons.bookmark_outline,
                      title: l10n.savedResources,
                      onTap: _showSavedResources,
                    ),
                    AppTile(
                      icon: Icons.logout,
                      title: l10n.logOut,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

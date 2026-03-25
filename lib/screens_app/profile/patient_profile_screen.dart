import 'package:ehnama3ak/core/widgets/app_button.dart';
import 'package:ehnama3ak/core/widgets/app_tile.dart';
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

  void _showEditProfileDialog(ProfileModel profile) {
    final nameCtrl = TextEditingController(text: profile.fullName);
    final imageCtrl = TextEditingController(text: profile.profileImageUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Profile Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.read<ProfileCubit>().updateProfile(nameCtrl.text, imageCtrl.text);
                // Sync with drawer
                context.read<SettingsCubit>().fetchSettings();
              },
              child: const Text('Save'),
            ),
          ],
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
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is UpdateProfileLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updating profile...'), duration: Duration(milliseconds: 500)),
          );
        } else if (state is UpdateProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) {
          return current is ProfileLoading || current is ProfileSuccess || current is ProfileError;
        },
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
                  Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Try Again'),
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
                          backgroundImage: profile.profileImageUrl.isNotEmpty
                              ? NetworkImage(profile.profileImageUrl)
                              : const AssetImage('assets/images/image_patient.png') as ImageProvider,
                          child: profile.profileImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Uploading image...')),
                                );
                                // Upload image using ProfileCubit to avoid global AuthLoading screen reset!
                                await context.read<ProfileCubit>().updateProfileImage(image.path);
                                
                                // Sync Drawer instantly
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
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ===== NAME + EDIT PROFILE =====
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ===== NAME & EMAIL =====
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName.isNotEmpty ? profile.fullName : 'No Name',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.email.isNotEmpty ? profile.email : 'No Email',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: AppButton(
                            label: 'Edit Profile',
                            onPressed: () => _showEditProfileDialog(profile),
                            icon: Icons.edit,
                            iconSize: 15,
                            width: 150,
                            height: 40,
                            radius: 20,
                            textStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatCard(title: 'Sessions', value: profile.sessionsCount.toString()),
                        StatCard(title: 'Exercises', value: profile.exercisesCount.toString()),
                        StatCard(title: 'Days', value: profile.daysCount.toString()),
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
                      onTap: _showSavedResources,
                    ),
                    AppTile(
                      icon: Icons.logout,
                      title: 'Log Out',
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

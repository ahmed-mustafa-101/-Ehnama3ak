// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../core/widgets/logout_dialog.dart';
// import '../../features/auth/presentation/controllers/auth_cubit.dart';

// class DoctorSettingsScreen extends StatelessWidget {
//   const DoctorSettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Column(
//         children: [
//           // ===== Doctor Header =====
//           _buildDoctorHeader(isDark),

//           const SizedBox(height: 20),

//           // ===== Edit Profile Button =====
//           SizedBox(
//             width: 220,
//             height: 45,
//             child: ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0DA5FE),
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Edit Profile',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),

//           const SizedBox(height: 30),

//           // ===== Settings Items =====
//           _buildSettingItem(
//             context,
//             Icons.notifications_active_outlined,
//             'Notifications',
//             hasDivider: true,
//           ),
//           _buildSettingItem(
//             context,
//             Icons.translate_rounded,
//             'Language',
//             trailingText: 'English',
//             hasDivider: true,
//           ),
//           const SizedBox(height: 20),
//           _buildSettingItem(
//             context,
//             Icons.verified_user_outlined,
//             'Security',
//             hasDivider: false,
//           ),
//           const SizedBox(height: 20),
//           _buildSettingItem(
//             context,
//             Icons.share_outlined,
//             'Share App',
//             hasDivider: false,
//           ),

//           const SizedBox(height: 30),

//           // ===== Support Section =====
//           const Align(
//             alignment: Alignment.centerLeft,
//             child: Padding(
//               padding: EdgeInsets.only(left: 10, bottom: 10),
//               child: Text(
//                 'Support',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),

//           _buildSettingItem(
//             context,
//             Icons.help_center_outlined,
//             'Support Center',
//             hasDivider: true,
//           ),
//           _buildSettingItem(
//             context,
//             Icons.lock_outline_rounded,
//             'Privacy Policy',
//             hasDivider: false,
//           ),

//           const SizedBox(height: 20),

//           _buildSettingItem(
//             context,
//             Icons.logout_rounded,
//             'Log Out',
//             isLogout: true,
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (_) => LogoutDialog(
//                   onLogout: () async {
//                     Navigator.pop(context);
//                     if (!context.mounted) return;
//                     context.read<AuthCubit>().logout();
//                   },
//                 ),
//               );
//             },
//           ),

//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }

//   Widget _buildDoctorHeader(bool isDark) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(3),
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [Color(0xFF0DA5FE), Colors.lightBlueAccent],
//             ),
//           ),
//           child: const CircleAvatar(
//             radius: 60,
//             backgroundImage: AssetImage('assets/images/image_doctor.png'),
//           ),
//         ),
//         const SizedBox(height: 15),
//         const Text(
//           'Dr. Ahmed Mosaad',
//           style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//         ),
//         const Text(
//           'Mental Health Specialist',
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//         const Text(
//           '5 Years Exp',
//           style: TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               children: List.generate(
//                 10,
//                 (index) => Icon(
//                   Icons.star,
//                   size: 16,
//                   color: index < 7
//                       ? const Color(0xFF0DA5FE)
//                       : Colors.grey.shade400,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 15),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.green.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Row(
//                 children: [
//                   CircleAvatar(radius: 4, backgroundColor: Colors.green),
//                   SizedBox(width: 5),
//                   Text(
//                     'Available',
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildSettingItem(
//     BuildContext context,
//     IconData icon,
//     String title, {
//     String? trailingText,
//     bool hasDivider = false,
//     bool isLogout = false,
//     VoidCallback? onTap,
//   }) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 2),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           if (!hasDivider)
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//         ],
//       ),
//       child: Column(
//         children: [
//           ListTile(
//             leading: Icon(
//               icon,
//               color: isLogout ? Colors.red : const Color(0xFF0DA5FE),
//               size: 28,
//             ),
//             title: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: isLogout
//                     ? Colors.red
//                     : (isDark ? Colors.white : Colors.black87),
//               ),
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (trailingText != null)
//                   Text(
//                     trailingText,
//                     style: const TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                 const SizedBox(width: 5),
//                 const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.grey,
//                 ),
//               ],
//             ),
//             onTap: onTap ?? () {},
//           ),
//           if (hasDivider)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Divider(
//                 height: 1,
//                 color: Colors.grey.withValues(alpha: 0.2),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/logout_dialog.dart';
import '../../core/widgets/registered_doctor_profile_texts.dart';
import '../../features/auth/data/models/auth_model.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';

class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // ===== Doctor Header =====
          _buildDoctorHeader(context, isDark),

          const SizedBox(height: 20),

          // ===== Edit Profile Button =====
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
                  onPressed: () => _showEditProfileDialog(context, user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0DA5FE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // ===== Settings Items =====
          _buildSettingItem(
            context,
            Icons.notifications_active_outlined,
            'Notifications',
            hasDivider: true,
            onTap: () {},
          ),

          _buildSettingItem(
            context,
            Icons.translate_rounded,
            'Language',
            trailingText: 'English',
            hasDivider: true,
            onTap: () {},
          ),

          const SizedBox(height: 20),

          _buildSettingItem(
            context,
            Icons.verified_user_outlined,
            'Security',
            onTap: () => _showChangePasswordDialog(context),
          ),

          const SizedBox(height: 20),

          _buildSettingItem(
            context,
            Icons.share_outlined,
            'Share App',
            onTap: () {},
          ),

          const SizedBox(height: 30),

          // ===== Support =====
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'Support',
                style: TextStyle(
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
            'Support Center',
            hasDivider: true,
            onTap: () => _showSupportInfo(context),
          ),

          _buildSettingItem(
            context,
            Icons.lock_outline_rounded,
            'Privacy Policy',
            onTap: () => _showPrivacyPolicy(context),
          ),

          const SizedBox(height: 20),

          _buildSettingItem(
            context,
            Icons.logout_rounded,
            'Log Out',
            isLogout: true,
            onTap: () => _showLogoutDialog(context),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context, bool isDark) {
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
        final nameStyle = TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        );
        final subStyle = TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
        );
        final yearsStyle = TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        );
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0DA5FE), Colors.lightBlueAccent],
                ),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/image_doctor.png'),
              ),
            ),
            const SizedBox(height: 15),
            RegisteredDoctorProfileTexts(
              user: user,
              crossAxisAlignment: CrossAxisAlignment.center,
              textAlign: TextAlign.center,
              nameStyle: nameStyle,
              specializationStyle: subStyle,
              yearsStyle: yearsStyle,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        'Available',
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

  void _showEditProfileDialog(BuildContext context, AuthModel? user) {
    final nameController = TextEditingController(
      text: user?.displayNameLine ?? '',
    );
    final emailController = TextEditingController(text: user?.email ?? '');
    final specController = TextEditingController(
      text: (user?.specialization ?? '').trim(),
    );
    final yearsController = TextEditingController(
      text: user?.yearsOfExperience?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              TextField(
                controller: specController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                ),
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
                'Profile data comes from your account. Update via support if needed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
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
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(diagContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: const Column(
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text('Your privacy policy content here...'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Support Center',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('support@doctorapp.com'),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('+20 100 000 0000'),
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

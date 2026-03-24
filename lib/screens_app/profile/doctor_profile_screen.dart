import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:ehnama3ak/core/widgets/registered_doctor_profile_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/main_layout.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, 20),
        vertical: Responsive.padding(context, 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header Row =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent],
                  ),
                ),
                child: CircleAvatar(
                  radius: Responsive.iconSize(context, 55),
                  backgroundImage: const AssetImage(
                    'assets/images/image_doctor.png',
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 15)),
              Expanded(
                child: BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (prev, curr) {
                    if (curr is AuthSuccess) {
                      if (prev is AuthSuccess) return prev.user != curr.user;
                      return true;
                    }
                    return prev is AuthSuccess;
                  },
                  builder: (context, state) {
                    final user =
                        state is AuthSuccess ? state.user : null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RegisteredDoctorProfileTexts(
                          user: user,
                          nameStyle: TextStyle(
                            fontSize: Responsive.fontSize(context, 24),
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          specializationStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: Responsive.fontSize(context, 16),
                          ),
                          yearsStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: Responsive.fontSize(context, 14),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 8)),

                        // Stars and Available badge - Responsive layout
                        Wrap(
                          spacing: Responsive.spacing(context, 8),
                          runSpacing: Responsive.spacing(context, 8),
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Stars
                            Wrap(
                              children: List.generate(
                                10,
                                (index) => Icon(
                                  Icons.star,
                                  size: Responsive.iconSize(context, 14),
                                  color: index < 7
                                      ? Colors.blue
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            // Available badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.padding(context, 10),
                                vertical: Responsive.padding(context, 4),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(
                                  Responsive.borderRadius(context, 20),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: Responsive.iconSize(context, 4),
                                    backgroundColor: Colors.green,
                                  ),
                                  SizedBox(
                                      width: Responsive.spacing(context, 5)),
                                  Text(
                                    'Available',
                                    style: TextStyle(
                                      color: const Color(0xFF0DA5FE),
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          Responsive.fontSize(context, 12),
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
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 30)),

          // ===== Up Next Appointment =====
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.padding(context, 16)),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF7FAFF).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(
                Responsive.borderRadius(context, 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Up Next Appointment',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 8)),
                Text(
                  'Patient: Aya Ahmed',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 16),
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 4)),
                Text(
                  'Today, 1:30 PM',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 30)),

          // ===== Dashboard Grid =====
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
            mainAxisSpacing: Responsive.spacing(context, 15),
            crossAxisSpacing: Responsive.spacing(context, 15),
            childAspectRatio: 1.9,
            children: [
              _dashboardItem(
                context,
                Icons.calendar_month_rounded,
                '7 Sessions',
                const Color(0xFF0DA5FE),
                5,
              ),
              _dashboardItem(
                context,
                Icons.notifications_rounded,
                '3 News',
                Colors.orange,
                -1,
              ),
              _dashboardItem(
                context,
                Icons.groups_rounded,
                '44 Patients',
                Colors.purple,
                6,
              ),
              _dashboardItem(
                context,
                Icons.chat_bubble_rounded,
                'Upcoming Sessions',
                const Color(0xFF0DA5FE),
                5,
              ),
              _dashboardItem(
                context,
                Icons.person_pin_rounded,
                'Patient Records',
                const Color(0xFF0DA5FE),
                6,
              ),
              _dashboardItem(
                context,
                Icons.analytics_rounded,
                'Reports',
                const Color(0xFF0DA5FE),
                7,
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 40)),

          // ===== Recent Activity =====
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 15)),
          _activityItem(
            context,
            Icons.check_box_rounded,
            'Patient Sara Hany Completed',
            'pre-session.',
            '15 min ago',
            const Color(0xFF0DA5FE),
          ),
          _activityItem(
            context,
            Icons.chat_bubble_rounded,
            'New message from Patient Omar Saad',
            'pre-session.',
            '19 min ago',
            const Color(0xFF0DA5FE),
          ),
          _activityItem(
            context,
            Icons.check_box_rounded,
            'Patient Amr Khaled scheduled a new session',
            'new session.',
            '30 min ago',
            const Color(0xFF0DA5FE),
          ),
        ],
      ),
    );
  }

  Widget _dashboardItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    int targetIndex,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (targetIndex != -1) {
          MainLayout.of(context)?.changeTab(targetIndex);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: Responsive.iconSize(context, 30)),
            SizedBox(height: Responsive.spacing(context, 8)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 4),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 11),
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String time,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context, 15)),
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 12)),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E1E)
              : const Color(0xFFF7FAFF).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, 12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: Responsive.iconSize(context, 28)),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(context, 14),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: Responsive.fontSize(context, 12),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: Responsive.fontSize(context, 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

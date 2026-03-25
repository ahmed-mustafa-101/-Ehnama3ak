import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:ehnama3ak/core/widgets/registered_doctor_profile_texts.dart';
import 'package:ehnama3ak/core/widgets/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_state.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/upload_models.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorDashboardCubit>().loadDashboardData();
  }

  void _showAddRecordDialog() {
    final patientIdCtrl = TextEditingController();
    final diagnosisCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final treatmentPlanCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Patient Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientIdCtrl,
                decoration: const InputDecoration(labelText: 'Patient ID'),
              ),
              TextField(
                controller: diagnosisCtrl,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
              ),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              TextField(
                controller: treatmentPlanCtrl,
                decoration: const InputDecoration(labelText: 'Treatment Plan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DoctorDashboardCubit>().addPatientRecord(
                AddRecordModel(
                  patientId: patientIdCtrl.text,
                  diagnosis: diagnosisCtrl.text,
                  notes: notesCtrl.text,
                  treatmentPlan: treatmentPlanCtrl.text,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUploadReportDialog() {
    final patientIdCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Medical Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: patientIdCtrl,
              decoration: const InputDecoration(labelText: 'Patient ID'),
            ),
            TextField(
              controller: typeCtrl,
              decoration: const InputDecoration(labelText: 'Report Type'),
            ),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(labelText: 'File URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DoctorDashboardCubit>().uploadReport(
                UploadReportModel(
                  id: 0,
                  doctorId: "", // Backend usually gets this from token
                  patientId: patientIdCtrl.text,
                  type: typeCtrl.text,
                  fileUrl: urlCtrl.text,
                  reportDate: DateTime.now().toIso8601String(),
                ),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<DoctorDashboardCubit, DoctorDashboardState>(
      listener: (context, state) {
        if (state is ActionLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Processing...'),
              duration: Duration(milliseconds: 500),
            ),
          );
        } else if (state is ActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is DoctorDashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<DoctorDashboardCubit, DoctorDashboardState>(
        builder: (context, state) {
          if (state is DoctorDashboardLoading ||
              state is DoctorDashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DoctorDashboardError) {
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
                    onPressed: () => context
                        .read<DoctorDashboardCubit>()
                        .loadDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DoctorDashboardSuccess) {
            final stats = state.stats;
            final activity = state.recentActivity;

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<DoctorDashboardCubit>().loadDashboardData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 20),
                  vertical: Responsive.padding(context, 10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Header Row =====
                    BlocBuilder<AuthCubit, AuthState>(
                      buildWhen: (prev, curr) {
                        if (curr is AuthSuccess) {
                          if (prev is AuthSuccess)
                            return prev.user != curr.user;
                          return true;
                        }
                        return prev is AuthSuccess;
                      },
                      builder: (context, authState) {
                        final user = authState is AuthSuccess
                            ? authState.user
                            : null;
                        return Row(
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
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    (user?.profileImageUrl != null &&
                                        user!.profileImageUrl!.isNotEmpty)
                                    ? NetworkImage(user.profileImageUrl!)
                                    : const AssetImage(
                                            'assets/images/image_doctor.png',
                                          )
                                          as ImageProvider,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 15)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RegisteredDoctorProfileTexts(
                                    user: user,
                                    nameStyle: TextStyle(
                                      fontSize: Responsive.fontSize(
                                        context,
                                        24,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    specializationStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: Responsive.fontSize(
                                        context,
                                        16,
                                      ),
                                    ),
                                    yearsStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: Responsive.fontSize(
                                        context,
                                        14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.spacing(context, 8),
                                  ),

                                  // Stars and Available badge
                                  Wrap(
                                    spacing: Responsive.spacing(context, 8),
                                    runSpacing: Responsive.spacing(context, 8),
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Wrap(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            Icons.star,
                                            size: Responsive.iconSize(
                                              context,
                                              14,
                                            ),
                                            color: index < 4
                                                ? Colors.blue
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Responsive.padding(
                                            context,
                                            10,
                                          ),
                                          vertical: Responsive.padding(
                                            context,
                                            4,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            Responsive.borderRadius(
                                              context,
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: Responsive.iconSize(
                                                context,
                                                4,
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                            SizedBox(
                                              width: Responsive.spacing(
                                                context,
                                                5,
                                              ),
                                            ),
                                            Text(
                                              'Available',
                                              style: TextStyle(
                                                color: const Color(0xFF0DA5FE),
                                                fontWeight: FontWeight.bold,
                                                fontSize: Responsive.fontSize(
                                                  context,
                                                  12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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
                            'Dashboard Stats',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 8)),
                          Text(
                            'Upcoming: ${stats.upcomingSessionsCount} Sessions',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w500,
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
                          '${stats.sessionsCount} Sessions',
                          const Color(0xFF0DA5FE),
                          5,
                        ),
                        _dashboardItem(
                          context,
                          Icons.notifications_rounded,
                          '${stats.newsCount} News',
                          Colors.orange,
                          -1,
                        ),
                        _dashboardItem(
                          context,
                          Icons.groups_rounded,
                          '${stats.patientsCount} Patients',
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
                          'Add Record',
                          const Color(0xFF1E88E5),
                          -2, // Special code for Add Record
                        ),
                        _dashboardItem(
                          context,
                          Icons.analytics_rounded,
                          'Upload Report',
                          const Color(0xFF43A047),
                          -3, // Special code for Upload Report
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
                    activity.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'No recent activity.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activity.length,
                            itemBuilder: (context, index) {
                              final item = activity[index];
                              return _activityItem(
                                context,
                                item.type == 'message'
                                    ? Icons.chat_bubble_rounded
                                    : Icons.check_box_rounded,
                                item.title,
                                item.description,
                                item.timeAgo,
                                const Color(0xFF0DA5FE),
                              );
                            },
                          ),
                    SizedBox(height: Responsive.spacing(context, 40)),

                    // ===== Medical Reports =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medical Reports',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showUploadReportDialog();
                          },
                          child: const Text('Upload New'),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 15)),
                    (state.medicalReports == null ||
                            state.medicalReports!.isEmpty)
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'No medical reports.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.medicalReports!.length,
                            itemBuilder: (context, index) {
                              final report = state.medicalReports![index];
                              return _activityItem(
                                context,
                                Icons.description_outlined,
                                report.type,
                                'Patient ID: ${report.patientId}',
                                report.reportDate.split('T').first,
                                const Color(0xFF43A047),
                              );
                            },
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
        if (targetIndex == -2) {
          _showAddRecordDialog();
        } else if (targetIndex == -3) {
          _showUploadReportDialog();
        } else if (targetIndex != -1) {
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

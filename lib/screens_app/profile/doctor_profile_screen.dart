import 'package:ehnama3ak/core/utils/responsive.dart';
import 'package:ehnama3ak/core/widgets/registered_doctor_profile_texts.dart';
import 'package:ehnama3ak/core/widgets/main_layout.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/controllers/auth_cubit.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_state.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
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

  String _getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 60000;
    return '$fullUrl?v=$ts';
  }

  void _showAddRecordDialog() {
    final l10n = AppLocalizations.of(context);
    final patientIdCtrl = TextEditingController();
    final diagnosisCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final treatmentPlanCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addPatientRecord),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patientIdCtrl,
                decoration: InputDecoration(labelText: l10n.patientId),
              ),
              TextField(
                controller: diagnosisCtrl,
                decoration: InputDecoration(labelText: l10n.diagnosis),
              ),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(labelText: l10n.notes),
              ),
              TextField(
                controller: treatmentPlanCtrl,
                decoration: InputDecoration(labelText: l10n.treatmentPlan),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0DA5FE),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.cancel),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0DA5FE),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showUploadReportDialog() {
    final l10n = AppLocalizations.of(context);
    final patientIdCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.uploadMedicalReport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: patientIdCtrl,
              decoration: InputDecoration(labelText: l10n.patientId),
            ),
            TextField(
              controller: typeCtrl,
              decoration: InputDecoration(labelText: l10n.reportType),
            ),
            TextField(
              controller: urlCtrl,
              decoration: InputDecoration(labelText: l10n.fileUrl),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0DA5FE),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DoctorDashboardCubit>().uploadReport(
                UploadReportModel(
                  id: 0,
                  doctorId: "",
                  patientId: patientIdCtrl.text,
                  type: typeCtrl.text,
                  fileUrl: urlCtrl.text,
                  reportDate: DateTime.now().toIso8601String(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0DA5FE),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.upload),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BlocListener<DoctorDashboardCubit, DoctorDashboardState>(
      listener: (context, state) {
        if (state is ActionLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.processing),
              duration: const Duration(milliseconds: 500),
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
                    child: Text(l10n.retry),
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
                    // Header
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
                                    ? NetworkImage(
                                        _getFullImageUrl(user.profileImageUrl!),
                                      )
                                    : const AssetImage(
                                            'assets/images/user_avatar.png',
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
                                              l10n.available,
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

                    // Dashboard Stats
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
                            l10n.dashboardStats,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 8)),
                          Text(
                            '${l10n.upcoming}: ${stats.upcomingSessionsCount} ${l10n.sessionsTitle}',
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

                    // Grid
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
                          l10n.sessionsTitle,
                          const Color(0xFF0DA5FE),
                          -1,
                          count: stats.sessionsCount,
                        ),
                        _dashboardItem(
                          context,
                          Icons.notifications_rounded,
                          l10n.news,
                          Colors.orange,
                          -1,
                          count: stats.newsCount,
                        ),
                        _dashboardItem(
                          context,
                          Icons.groups_rounded,
                          l10n.patients,
                          Colors.purple,
                          -1,
                          count: stats.patientsCount,
                        ),
                        _dashboardItem(
                          context,
                          Icons.chat_bubble_rounded,
                          l10n.upcomingSessions,
                          const Color(0xFF0DA5FE),
                          -1,
                          count: stats.upcomingSessionsCount,
                        ),
                        _dashboardItem(
                          context,
                          Icons.person_pin_rounded,
                          l10n.addRecord,
                          const Color(0xFF1E88E5),
                          -2,
                        ),
                        _dashboardItem(
                          context,
                          Icons.analytics_rounded,
                          l10n.upload,
                          const Color(0xFF43A047),
                          -3,
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 40)),

                    // Recent Activity
                    Text(
                      l10n.recentActivity,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 15)),
                    activity.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                l10n.noRecentActivity,
                                style: const TextStyle(color: Colors.grey),
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

                    // Medical Reports
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.medicalReports,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 22),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _showUploadReportDialog,
                          child: Text(l10n.uploadNew),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 15)),
                    (state.medicalReports == null ||
                            state.medicalReports!.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                l10n.noMedicalReports,
                                style: const TextStyle(color: Colors.grey),
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
    int targetIndex, {
    int count = 0,
  }) {
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
            Icon(icon, color: color, size: Responsive.iconSize(context, 26)),
            SizedBox(height: Responsive.spacing(context, 8)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 4),
              ),
              child: Text(
                '$count $label',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 13),
                  fontWeight: FontWeight.bold,
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

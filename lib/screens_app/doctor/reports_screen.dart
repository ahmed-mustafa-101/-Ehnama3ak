import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reports/presentation/cubit/doctor_reports_cubit.dart';
import 'reports/presentation/cubit/doctor_reports_state.dart';
import 'reports/models/doctor_report_model.dart';

class DoctorReportsScreen extends StatefulWidget {
  const DoctorReportsScreen({super.key});

  @override
  State<DoctorReportsScreen> createState() => _DoctorReportsScreenState();
}

class _DoctorReportsScreenState extends State<DoctorReportsScreen> {
  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    context.read<DoctorReportsCubit>().fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Reports',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF0DA5FE),
            onRefresh: () async => _loadReports(),
            child: BlocBuilder<DoctorReportsCubit, DoctorReportsState>(
              builder: (context, state) {
                if (state is DoctorReportsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DoctorReportsError) {
                  return _buildErrorState(state.message);
                } else if (state is DoctorReportsLoaded) {
                  if (state.reports.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.reports.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final report = state.reports[index];
                      return _buildReportItem(context, report);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            children: [
              Icon(Icons.description_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No reports found.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadReports,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportItem(BuildContext context, DoctorReportModel report) {
    // Detect icon and color based on type
    IconData icon;
    Color color = const Color(0xFF0DA5FE);

    final type = report.type?.toLowerCase() ?? '';
    if (type.contains('progress')) {
      icon = Icons.assignment_outlined;
    } else if (type.contains('weekly')) {
      icon = Icons.bar_chart;
    } else if (type.contains('assessment')) {
      icon = Icons.donut_large;
    } else {
      icon = Icons.description_outlined;
    }

    return _reportItem(
      context,
      report.title ?? 'No Title',
      report.patientName ?? 'No Patient',
      report.date ?? 'No Date',
      icon,
      color,
    );
  }

  Widget _reportItem(
    BuildContext context,
    String title,
    String subtitle,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

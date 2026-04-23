import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
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

  void _loadReports() => context.read<DoctorReportsCubit>().fetchReports();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.reportsTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF0DA5FE),
            onRefresh: () async => _loadReports(),
            child: BlocBuilder<DoctorReportsCubit, DoctorReportsState>(
              builder: (context, state) {
                if (state is DoctorReportsLoading) return const Center(child: CircularProgressIndicator());
                if (state is DoctorReportsError) return _buildErrorState(state.message, l10n);
                if (state is DoctorReportsLoaded) {
                  if (state.reports.isEmpty) return _buildEmptyState(l10n);
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.reports.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) => _buildReportItem(context, state.reports[index]),
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
      Center(child: Column(children: [
        const Icon(Icons.description_outlined, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        Text(l10n.noReports, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ])),
    ]);
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
    return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
      Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _loadReports, child: Text(l10n.retry)),
      ]))),
    ]);
  }

  Widget _buildReportItem(BuildContext context, DoctorReportModel report) {
    IconData icon;
    const Color color = Color(0xFF0DA5FE);
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

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.patientName ?? 'No Patient',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report.type ?? 'Report',
                        style: const TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            report.date ?? 'No Date',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

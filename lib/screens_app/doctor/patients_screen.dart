import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'doctor_patients/presentation/cubit/doctor_patients_cubit.dart';
import 'doctor_patients/presentation/cubit/doctor_patients_state.dart';
import '../messages/chat_navigator.dart';
import 'patient_detail_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});
  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DoctorPatientsCubit>().fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  context.read<DoctorPatientsCubit>().searchPatients(value),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: Color(0xFF0DA5FE)),
                hintText: l10n.myPatients,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF0DA5FE),
            onRefresh: () async {
              _searchController.clear();
              await context.read<DoctorPatientsCubit>().fetchPatients();
            },
            child: BlocBuilder<DoctorPatientsCubit, DoctorPatientsState>(
              builder: (context, state) {
                if (state is DoctorPatientsLoading ||
                    state is DoctorPatientsSearching) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DoctorPatientsError) {
                  return _buildErrorState(state.message, l10n);
                } else if (state is DoctorPatientsLoaded) {
                  if (state.patients.isEmpty) return _buildEmptyState(l10n);
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.patients.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      return _patientItem(
                        context,
                        patient.fullName ?? 'Unknown',
                        patient.diagnosis ?? 'No Diagnosis',
                        patient.lastSessionDate ?? 'N/A',
                        patient.profileImageUrl,
                        patient.id,
                        l10n,
                      );
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              const Icon(Icons.person_search, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.noPatients,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
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
                  onPressed: () =>
                      context.read<DoctorPatientsCubit>().fetchPatients(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _patientItem(
    BuildContext context,
    String name,
    String condition,
    String lastSession,
    String? imageUrl,
    String? id,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                ? NetworkImage(imageUrl)
                : null,
            child: (imageUrl == null || imageUrl.isEmpty)
                ? const Icon(Icons.person, color: Color(0xFF0DA5FE))
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  condition,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.lastSession}: $lastSession',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (id != null) {
                      ChatNavigator.open(
                        context,
                        userId: id,
                        userName: name,
                        profileImage: imageUrl,
                      );
                    }
                  },
                  icon: Image.asset(
                    'assets/images/messageicon.png',
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () {
                  if (id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientDetailScreen(
                          id: id,
                          name: name,
                          diagnosis: condition,
                          lastSession: lastSession,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF0DA5FE,
                  ).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFF0DA5FE),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(l10n.view, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

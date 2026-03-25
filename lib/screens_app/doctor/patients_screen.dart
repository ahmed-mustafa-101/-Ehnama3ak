import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'doctor_patients/presentation/cubit/doctor_patients_cubit.dart';
import 'doctor_patients/presentation/cubit/doctor_patients_state.dart';

import '../messages/message_detail_screen.dart';

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
    return Column(
      children: [
        const SizedBox(height: 10),
        // Search Bar
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
              onChanged: (value) {
                context.read<DoctorPatientsCubit>().searchPatients(value);
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Color(0xFF0DA5FE)),
                hintText: 'My Patients',
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
                  return _buildErrorState(state.message);
                } else if (state is DoctorPatientsLoaded) {
                  if (state.patients.isEmpty) {
                    return _buildEmptyState();
                  }
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

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            children: [
              Icon(Icons.person_search, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No patients found.",
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
                  onPressed: () {
                    context.read<DoctorPatientsCubit>().fetchPatients();
                  },
                  child: const Text("Retry"),
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
                ),
                Text(
                  condition,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  'Last Session: $lastSession',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageDetailScreen(
                          receiverId: id,
                          receiverName: name,
                          receiverProfileImage: imageUrl,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.message_rounded,
                  color: Color(0xFF0DA5FE),
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF0DA5FE,
                  ).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFF0DA5FE),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

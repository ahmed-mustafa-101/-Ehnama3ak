import 'package:flutter/material.dart';
import 'package:ehnama3ak/core/models/user_role.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'patient_profile_screen.dart';
import 'doctor_profile_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole>(
      future: PrefManager.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final role = snapshot.data ?? UserRole.patient;
        
        if (role == UserRole.doctor) {
          return const DoctorProfileScreen();
        }
        
        return const PatientProfileScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/screens_app/messages/chat_navigator.dart';

class PatientDetailScreen extends StatelessWidget {
  final String id;
  final String name;
  final String diagnosis;
  final String lastSession;
  final String? imageUrl;

  const PatientDetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.diagnosis,
    required this.lastSession,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = const Color(0xFF0DA5FE);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.patientsTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with Image and Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: color.withValues(alpha: 0.1),
                    backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                        ? NetworkImage(imageUrl!)
                        : null,
                    child: (imageUrl == null || imageUrl!.isEmpty)
                        ? Icon(Icons.person, size: 60, color: color)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Info Section
            _buildInfoCard(
              context,
              title: l10n.diagnosis,
              value: diagnosis,
              icon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: l10n.lastSession,
              value: lastSession,
              icon: Icons.event_available,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: l10n.patientId,
              value: id,
              icon: Icons.fingerprint,
            ),

            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ChatNavigator.open(
                      context,
                      userId: id,
                      userName: name,
                      profileImage: imageUrl,
                    ),
                    icon: const Icon(Icons.message_rounded),
                    label: Text(l10n.messageLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              color: const Color(0xFF0DA5FE).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0DA5FE), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

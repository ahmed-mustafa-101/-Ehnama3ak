import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sessions/presentation/cubit/doctor_sessions_cubit.dart';
import 'sessions/presentation/cubit/doctor_sessions_state.dart';
import 'sessions/models/doctor_session_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_session_screen.dart';

class DoctorSessionsScreen extends StatefulWidget {
  const DoctorSessionsScreen({super.key});

  @override
  State<DoctorSessionsScreen> createState() => _DoctorSessionsScreenState();
}

class _DoctorSessionsScreenState extends State<DoctorSessionsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    context.read<DoctorSessionsCubit>().fetchUpcomingSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildHeader(context),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF0EA5E9),
            onRefresh: () async => _loadSessions(),
            child: BlocBuilder<DoctorSessionsCubit, DoctorSessionsState>(
              builder: (context, state) {
                if (state is DoctorSessionsLoading) {
                  return _buildLoadingState();
                } else if (state is DoctorSessionsError) {
                  return _buildErrorState(state.message);
                } else if (state is DoctorSessionsLoaded) {
                  if (state.sessions.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildSessionsList(state.sessions);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'Sessions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSessionScreen(),
                ),
              );
              // Cubit handles refresh on success, but manual refresh doesn't hurt
              _loadSessions();
            },
            child: Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Add",
                  style: TextStyle(
                    color: Color(0xFF0EA5E9),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsList(List<DoctorSessionModel> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: sessions.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _sessionCard(context, session);
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
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
              Icon(Icons.event_note, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No sessions added yet.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Click 'Add' to create your first session.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
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
                const Text(
                  "Server Connection Error",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadSessions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text("Try Again"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sessionCard(BuildContext context, DoctorSessionModel session) {
    // If status is null or not 'completed'/'cancelled', treat as upcoming-capable
    final String status = session.status?.toLowerCase() ?? 'upcoming';
    final bool canStart = status == 'upcoming' || status == 'pending';

    final String displayDate =
        session.date ??
        (session.scheduledAt != null
            ? DateFormat('EEEE, MMM d, yyyy').format(session.scheduledAt!)
            : 'No Date');
    final String displayTime =
        session.time ??
        (session.scheduledAt != null
            ? DateFormat('h:mm a').format(session.scheduledAt!)
            : 'No Time');
    final String sessionType = session.sessionType ?? 'Session';

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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.patientName ?? 'Unknown Patient',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$displayDate - $displayTime",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    if (session.price != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Price: ${session.price} EGP",
                        style: const TextStyle(
                          color: Color(0xFF0EA5E9),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          sessionType.toLowerCase() == 'chat'
                              ? Icons.chat_outlined
                              : Icons.videocam_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$sessionType Session',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    sessionType.toLowerCase() == 'chat'
                        ? Icons.chat
                        : Icons.videocam,
                    color: const Color(0xFF0DA5FE),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(status),
                ],
              ),
            ],
          ),
          if (canStart) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (session.sessionUrl != null &&
                      session.sessionUrl!.isNotEmpty) {
                    final uri = Uri.tryParse(session.sessionUrl!);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Could not launch session link"),
                          ),
                        );
                      }
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("No session link available"),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.play_circle_filled, size: 18),
                label: const Text('Start Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0DA5FE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'pending':
        color = const Color(0xFF0DA5FE);
        label = 'UPCOMING';
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

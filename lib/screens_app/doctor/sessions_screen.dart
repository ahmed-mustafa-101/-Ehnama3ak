import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'sessions/presentation/cubit/doctor_sessions_cubit.dart';
import 'sessions/presentation/cubit/doctor_sessions_state.dart';
import 'sessions/models/doctor_session_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_session_screen.dart';
import '../messages/chat_navigator.dart';
import 'sessions/presentation/pages/session_media_viewer.dart';

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

  void _loadSessions() => context.read<DoctorSessionsCubit>().fetchAllSessions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildHeader(context, l10n),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFF0EA5E9),
            onRefresh: () async => _loadSessions(),
            child: BlocBuilder<DoctorSessionsCubit, DoctorSessionsState>(
              builder: (context, state) {
                if (state is DoctorSessionsLoading) return _buildLoadingState();
                if (state is DoctorSessionsError) return _buildErrorState(state.message, l10n);
                if (state is DoctorSessionsLoaded) {
                  if (state.sessions.isEmpty) return _buildEmptyState(l10n);
                  return _buildSessionsList(state.sessions, l10n);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.sessionsTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSessionScreen()));
              _loadSessions();
            },
            child: Row(
              children: [
                Container(
                  height: 28, width: 28,
                  decoration: BoxDecoration(color: const Color(0xFF0EA5E9), borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 6),
                Text(l10n.add, style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsList(List<DoctorSessionModel> sessions, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: sessions.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) => _sessionCard(context, sessions[index], l10n),
    );
  }

  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)));

  Widget _buildEmptyState(AppLocalizations l10n) {
    return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
      Center(child: Column(children: [
        const Icon(Icons.event_note, size: 60, color: Colors.grey),
        const SizedBox(height: 16),
        Text(l10n.noSessions, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(l10n.clickAddSession, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ])),
    ]);
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
    return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.2),
      Center(child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(l10n.serverConnectionError, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSessions,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Text(l10n.tryAgain)),
          ),
        ]),
      )),
    ]);
  }

  Widget _sessionCard(BuildContext context, DoctorSessionModel session, AppLocalizations l10n) {
    final String status = session.status?.toLowerCase() ?? 'upcoming';
    final bool canStart = status == 'upcoming' || status == 'pending';
    final String displayDate = session.date ?? (session.scheduledAt != null
        ? DateFormat('EEEE, MMM d, yyyy').format(session.scheduledAt!) : 'No Date');
    final String displayTime = session.time ?? (session.scheduledAt != null
        ? DateFormat('h:mm a').format(session.scheduledAt!) : 'No Time');
    final String sessionType = session.sessionType ?? 'Session';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(session.patientName ?? 'Unknown Patient',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("$displayDate - $displayTime",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                if (session.price != null) ...[
                  const SizedBox(height: 4),
                  Text("Price: ${session.price} EGP",
                      style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  Icon(_getSessionIcon(sessionType), size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text('$sessionType Session',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Icon(_getSessionIcon(sessionType, large: true), color: const Color(0xFF0DA5FE), size: 28),
                const SizedBox(height: 8),
                _buildStatusBadge(status),
              ]),
            ],
          ),
          if (canStart) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final type = session.sessionType?.toLowerCase() ?? '';
                  final patientId = session.patientId;
                  if (type.contains('chat') && patientId != null && patientId.isNotEmpty) {
                    ChatNavigator.open(
                      context,
                      userId: patientId,
                      userName: session.patientName ?? 'Patient',
                    );
                    return;
                  }
                  if (type.contains('video') || type.contains('audio') || type.contains('pdf') || type.contains('image')) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SessionMediaViewer(session: session)));
                    return;
                  }
                  if (session.sessionUrl != null && session.sessionUrl!.isNotEmpty) {
                    final uri = Uri.tryParse(session.sessionUrl!);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.couldNotLaunch)));
                    }
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.noSessionLink)));
                  }
                },
                icon: const Icon(Icons.play_circle_filled, size: 18),
                label: Text(l10n.startSession),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0DA5FE), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
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
      case 'upcoming': case 'pending': color = const Color(0xFF0DA5FE); label = 'UPCOMING'; break;
      case 'completed': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  IconData _getSessionIcon(String type, {bool large = false}) {
    switch (type.toLowerCase()) {
      case 'chat': return large ? Icons.chat : Icons.chat_outlined;
      case 'video': return large ? Icons.videocam : Icons.videocam_outlined;
      case 'audio': return large ? Icons.mic : Icons.mic_none;
      case 'pdf': return large ? Icons.description : Icons.description_outlined;
      default: return large ? Icons.event : Icons.event_outlined;
    }
  }
}

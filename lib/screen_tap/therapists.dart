import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_cubit.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_state.dart';
import 'package:ehnama3ak/screen_tap/therapist/models/doctor_model.dart';
import 'package:ehnama3ak/screens_app/messages/chat_navigator.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import 'package:ehnama3ak/screens_app/payment/payment_screen.dart';

class TherapistsPage extends StatefulWidget {
  final bool showHeader;
  const TherapistsPage({super.key, this.showHeader = true});
  @override
  State<TherapistsPage> createState() => _TherapistsPageState();
}

class _TherapistsPageState extends State<TherapistsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DoctorCubit>().loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBookingDialog(DoctorModel doctor) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String selectedType = 'Video';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24 + bottomInsets,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.bookSessionWith} ${doctor.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.sessionType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType,
                      items: ['Video', 'Audio', 'Chat']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.sessionDate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedDate == null
                            ? l10n.selectDate
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (dt != null) setState(() => selectedDate = dt);
                      },
                    ),
                    Text(
                      l10n.sessionTime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedTime == null
                            ? l10n.selectTime
                            : selectedTime!.format(context),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final tm = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (tm != null) setState(() => selectedTime = tm);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF0DA5FE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (selectedDate == null || selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.pleaseSelectDateTime),
                              ),
                            );
                            return;
                          }
                          final dt = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );
                          
                          // Capture navigator before popping the bottom sheet
                          final navigator = Navigator.of(context);
                          
                          navigator.pop(); // Close bottom sheet
                          navigator.push(
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                amount: 50.0,
                                onPaymentSuccess: () {
                                  // Use the state's context for the cubit call
                                  this.context.read<DoctorCubit>().bookSession(
                                    doctor.id,
                                    dt.toUtc().toIso8601String(),
                                    selectedType,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Text(l10n.confirmBooking),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is BookSessionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is DoctorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is BookSessionLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.bookingSession),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.showHeader) ...[
                const SizedBox(height: 12),
                _buildHeader(l10n),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: BlocBuilder<DoctorCubit, DoctorState>(
                  buildWhen: (p, c) =>
                      c is DoctorLoading ||
                      c is DoctorSuccess ||
                      c is DoctorInitial ||
                      c is DoctorError,
                  builder: (context, state) {
                    if (state is DoctorLoading || state is DoctorInitial)
                      return const Center(child: CircularProgressIndicator());
                    if (state is DoctorError)
                      return _buildErrorState(state.message, l10n);
                    if (state is DoctorSuccess) {
                      if (state.doctors.isEmpty) return _buildEmptyState(l10n);
                      return _buildDoctorsList(state.doctors, l10n);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 150,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E88E5), const Color(0xFF2C3E50)]
                : [const Color(0xFFD7F0FF), const Color(0xFFEAEAEA)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1F3A4A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) =>
                    context.read<DoctorCubit>().searchDoctors(val),
                decoration: InputDecoration(
                  hintText: l10n.searchDoctor,
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            context.read<DoctorCubit>().loadDoctors();
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/therapy.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<DoctorCubit>().loadDoctors(),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.noDoctorsFound,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getFullImageUrl(String? url) {
    if (url == null ||
        url.isEmpty ||
        url.toLowerCase() == 'null' ||
        url.toLowerCase() == 'string')
      return '';
    String cleanUrl = url.replaceAll('\\', '/');
    final String fullUrl = cleanUrl.startsWith('http')
        ? cleanUrl
        : '${DioClient.baseUrl}${cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl'}';
    return fullUrl;
  }

  Widget _buildDoctorsList(List<DoctorModel> doctors, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async => context.read<DoctorCubit>().loadDoctors(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          final fullImageUrl = _getFullImageUrl(doctor.imageUrl);

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: fullImageUrl.isNotEmpty
                            ? NetworkImage(fullImageUrl)
                            : null,
                        child: fullImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 36)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialization,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blueAccent,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                Text(
                                  doctor.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.work_outline,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                Text(
                                  '${doctor.experienceYears} ${l10n.years}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFF0DA5FE),
                            foregroundColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _showBookingDialog(doctor),
                          child: Text(l10n.bookSession),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => ChatNavigator.open(
                          context,
                          // Use the GUID userId for messaging API (receiverId).
                          // Fall back to numeric id only if userId is missing.
                          userId: doctor.userId.isNotEmpty
                              ? doctor.userId
                              : doctor.id.toString(),
                          userName: doctor.name,
                          profileImage: doctor.imageUrl,
                        ),
                        child: Image.asset(
                          'assets/images/messageicon.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_cubit.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_state.dart';
import 'package:ehnama3ak/screen_tap/therapist/models/doctor_model.dart';

class TherapistsPage extends StatefulWidget {
  const TherapistsPage({super.key});

  @override
  State<TherapistsPage> createState() => _TherapistsPageState();
}

class _TherapistsPageState extends State<TherapistsPage> {
  final TextEditingController _searchController = TextEditingController();

  // Debounce for search to avoid spamming the API
  bool _isSearching = false;

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
        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: 24.0 + bottomInsets,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book a Session with Dr. ${doctor.name}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Session Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType,
                      items: ['Video', 'Audio', 'Chat'].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Session Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedDate == null
                            ? 'Select Date'
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
                    const Text(
                      'Session Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedTime == null
                            ? 'Select Time'
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (selectedDate == null || selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select both date and time',
                                ),
                              ),
                            );
                            return;
                          }

                          // Convert to ISO 8601 string
                          final finalDateTime = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );

                          Navigator.pop(context);
                          context.read<DoctorCubit>().bookSession(
                            doctor.id,
                            finalDateTime.toUtc().toIso8601String(),
                            selectedType,
                          );
                        },
                        child: const Text('Confirm Booking'),
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
            const SnackBar(
              content: Text('Booking session...'),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<DoctorCubit, DoctorState>(
                  buildWhen: (previous, current) {
                    return current is DoctorLoading ||
                        current is DoctorSuccess ||
                        current is DoctorInitial ||
                        current is DoctorError;
                  },
                  builder: (context, state) {
                    if (state is DoctorLoading || state is DoctorInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is DoctorError) {
                      return _buildErrorState(state.message);
                    }
                    if (state is DoctorSuccess) {
                      if (state.doctors.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildDoctorsList(state.doctors);
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

  Widget _buildHeader() {
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
                onChanged: (val) {
                  // To avoid spamming, one might use a debouncer. Kept simple for now.
                  context.read<DoctorCubit>().searchDoctors(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search a doctor',
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
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No doctors found.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(List<DoctorModel> doctors) {
    return RefreshIndicator(
      onRefresh: () async => context.read<DoctorCubit>().loadDoctors(),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: doctors.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
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
                        backgroundImage: doctor.imageUrl.isNotEmpty
                            ? NetworkImage(doctor.imageUrl)
                            : null,
                        child: doctor.imageUrl.isEmpty
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
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialization,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  doctor.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.work_outline,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${doctor.experienceYears} Years',
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showBookingDialog(doctor),
                      child: const Text('Book Session'),
                    ),
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

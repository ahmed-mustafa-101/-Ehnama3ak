import 'package:ehnama3ak/screen_tap/progress/models/assessment_details_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/latest_assessment_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/mood_weekly_model.dart';
import 'package:ehnama3ak/screen_tap/progress/presentation/cubit/progress_cubit.dart';
import 'package:ehnama3ak/screen_tap/progress/presentation/cubit/progress_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage({super.key});

  @override
  State<MyProgressPage> createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data when Progress screen opens
    context.read<ProgressCubit>().loadProgressData();
  }

  void _showSaveMoodDialog() {
    int selectedValue = 3; // Default
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('How are you feeling today?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('1 = Very Bad, 5 = Very Good'),
                  Slider(
                    value: selectedValue.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: selectedValue.toString(),
                    onChanged: (val) {
                      setState(() {
                        selectedValue = val.toInt();
                      });
                    },
                  ),
                  Text(
                    'Selected Mood Level: $selectedValue',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<ProgressCubit>().saveMood(selectedValue);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssessmentDetailsDialog(AssessmentDetailsModel details) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                details.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: ${details.score}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Recommendation:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                details.recommendation,
                style: const TextStyle(fontSize: 14),
              ),

              if (details.answers != null && details.answers!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Answers:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...details.answers!.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.toString())),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ProgressCubit, ProgressState>(
              listener: (context, state) {
                if (state is ProgressActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is ProgressError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is ProgressActionLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saving mood...'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                }
              },
              buildWhen: (previous, current) {
                // Do not rebuild the whole screen on action loading/success, only on major state changes
                return current is ProgressLoading ||
                    current is ProgressError ||
                    current is ProgressSuccess;
              },
              builder: (context, state) {
                if (state is ProgressLoading || state is ProgressInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProgressError) {
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<ProgressCubit>().loadProgressData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => context
                                    .read<ProgressCubit>()
                                    .loadProgressData(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (state is ProgressSuccess) {
                  final moodWeekly = state.moodWeekly;
                  final latestAssessment = state.latestAssessment;
                  final assessmentDetails = state.assessmentDetails;

                  if (moodWeekly.isEmpty &&
                      latestAssessment == null &&
                      assessmentDetails == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            "No progress data available",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProgressCubit>()
                                .loadProgressData(),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<ProgressCubit>().loadProgressData(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 24.0,
                      ),
                      children: [
                        // الزر الجديد الثابت أعلى المحتوى بدلا من الزر العائم
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton.icon(
                        //     onPressed: _showSaveMoodDialog,
                        //     icon: const Icon(Icons.add_reaction, size: 24),
                        //     label: const Text(
                        //       'Log Daily Mood',
                        //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        //     ),
                        //     style: ElevatedButton.styleFrom(
                        //       padding: const EdgeInsets.symmetric(vertical: 18),
                        //       backgroundColor: Color(0xFF0DA5FE),
                        //       foregroundColor: Colors.white,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(16),
                        //       ),
                        //       elevation: 4,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 32),
                        if (moodWeekly.isNotEmpty)
                          _buildMoodGraph(moodWeekly)
                        else
                          const _EmptyDataCard(
                            message: 'No weekly mood data available',
                          ),

                        const SizedBox(height: 24),

                        if (latestAssessment != null)
                          _buildLatestAssessment(latestAssessment)
                        else
                          const _EmptyDataCard(
                            message: 'No latest assessment data available',
                          ),

                        const SizedBox(height: 24),

                        if (assessmentDetails != null)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                _showAssessmentDetailsDialog(assessmentDetails),
                            icon: const Icon(Icons.analytics),
                            label: const Text(
                              'View Assessment Details',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),

            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showSaveMoodDialog,
                  icon: const Icon(Icons.add_reaction),
                  label: const Text(
                    'Log Daily Mood',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DA5FE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodGraph(List<MoodWeeklyModel> data) {
    // Dynamic mood graph building
    double maxVal = 5.0; // Assume mood max value is 5
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.blueAccent),
                const SizedBox(width: 8),
                const Text(
                  'Weekly Mood Graph',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  double heightFactor = (item.value / maxVal).clamp(0.0, 1.0);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.value.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 24,
                          height: 100 * heightFactor,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.lightBlueAccent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.day,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestAssessment(LatestAssessmentModel data) {
    // Dynamic percentage circle
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              data.assessmentName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              width: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: (data.percentage / 100.0).clamp(0.0, 1.0),
                    ),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[200],
                        color: _getPercentageColor(data.percentage),
                      );
                    },
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${data.percentage}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getPercentageColor(data.percentage).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data.symptomLevel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getPercentageColor(data.percentage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(num percentage) {
    if (percentage < 30) return Colors.green;
    if (percentage < 60) return Colors.orange;
    return Colors.redAccent;
  }
}

class _EmptyDataCard extends StatelessWidget {
  final String message;
  const _EmptyDataCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

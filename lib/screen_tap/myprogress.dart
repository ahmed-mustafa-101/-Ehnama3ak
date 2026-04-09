import 'package:ehnama3ak/screen_tap/progress/models/assessment_details_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/latest_assessment_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/mood_weekly_model.dart';
import 'package:ehnama3ak/screen_tap/progress/presentation/cubit/progress_cubit.dart';
import 'package:ehnama3ak/screen_tap/progress/presentation/cubit/progress_state.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
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
    context.read<ProgressCubit>().loadProgressData();
  }

  void _showSaveMoodDialog() {
    int selectedValue = 3;
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.howFeelingToday),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.moodScale),
                  Slider(
                    value: selectedValue.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: const Color(0xff0DA5FE),
                    label: selectedValue.toString(),
                    onChanged: (val) => setState(() => selectedValue = val.toInt()),
                  ),
                  Text(
                    '${l10n.selectedMood}: $selectedValue',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xff0DA5FE),
                  ),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<ProgressCubit>().saveMood(selectedValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0DA5FE),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.save),
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
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(details.title,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Score: ${details.score}',
                    style: const TextStyle(fontSize: 16, color: Color(0xff0DA5FE), fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Recommendation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(details.recommendation, style: const TextStyle(fontSize: 14)),
                if (details.answers != null && details.answers!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Answers:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...details.answers!.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.toString())),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.closeDetails),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProgressTitle)),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ProgressCubit, ProgressState>(
              listener: (context, state) {
                if (state is ProgressActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                  );
                } else if (state is ProgressError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                } else if (state is ProgressActionLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.savingMood), duration: const Duration(milliseconds: 500)),
                  );
                }
              },
              buildWhen: (previous, current) =>
                  current is ProgressLoading || current is ProgressError || current is ProgressSuccess,
              builder: (context, state) {
                if (state is ProgressLoading || state is ProgressInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProgressError) {
                  return RefreshIndicator(
                    onRefresh: () async => context.read<ProgressCubit>().loadProgressData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(state.message, textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red, fontSize: 16)),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => context.read<ProgressCubit>().loadProgressData(),
                                icon: const Icon(Icons.refresh),
                                label: Text(l10n.tryAgain),
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

                  if (moodWeekly.isEmpty && latestAssessment == null && assessmentDetails == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(l10n.noProgressData,
                              style: const TextStyle(fontSize: 18, color: Colors.grey)),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.read<ProgressCubit>().loadProgressData(),
                            child: Text(l10n.refresh),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context.read<ProgressCubit>().loadProgressData(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      children: [
                        if (moodWeekly.isNotEmpty)
                          _buildMoodGraph(moodWeekly)
                        else
                          _EmptyDataCard(message: l10n.noProgressData),
                        const SizedBox(height: 24),
                        if (latestAssessment != null)
                          _buildLatestAssessment(latestAssessment)
                        else
                          _EmptyDataCard(message: l10n.noProgressData),
                        const SizedBox(height: 24),
                        if (assessmentDetails != null)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _showAssessmentDetailsDialog(assessmentDetails),
                            icon: const Icon(Icons.analytics),
                            label: Text(l10n.viewAssessmentDetails,
                                style: const TextStyle(fontSize: 16)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showSaveMoodDialog,
                  icon: const Icon(Icons.add_reaction),
                  label: Text(l10n.todaysMood,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0DA5FE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).helloHowFeel,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1D1B20))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((item) {
                final Map<int, Map<String, dynamic>> moodConfig = {
                  1: {'emoji': '😢', 'color': isDark ? const Color(0x33FF5252) : const Color(0xFFFFEBEE)},
                  2: {'emoji': '☹️', 'color': isDark ? const Color(0x33E040FB) : const Color(0xFFF3E5F5)},
                  3: {'emoji': '😐', 'color': isDark ? const Color(0x33448AFF) : const Color(0xFFE3F2FD)},
                  4: {'emoji': '🙂', 'color': isDark ? const Color(0x331DE9B6) : const Color(0xFFE0F2F1)},
                  5: {'emoji': '😄', 'color': isDark ? const Color(0x3369F0AE) : const Color(0xFFE8F5E9)},
                };
                final config = moodConfig[item.value] ?? {'emoji': '', 'color': Colors.transparent};
                final Color capsuleColor = config['color'] as Color;
                final String emoji = config['emoji'] as String;
                double barHeight = item.value == 0 ? 0 : 40 + (item.value * 18.0);
                bool isToday = data.indexOf(item) == data.length - 2;

                return Expanded(
                  child: Column(
                    children: [
                      Builder(builder: (context) {
                        String dayShort = item.day.length > 3 ? item.day.substring(0, 3) : item.day;
                        if (dayShort.isNotEmpty) {
                          dayShort = dayShort[0].toUpperCase() + dayShort.substring(1).toLowerCase();
                        }
                        return Text(dayShort,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? (isDark ? Colors.white : Colors.black) : Colors.grey.shade500));
                      }),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        width: 44,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            if (item.value == 0)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isToday) const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
                                  Container(
                                    height: 38, width: 38,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200, width: 2)),
                                  ),
                                ],
                              )
                            else
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutBack,
                                height: barHeight, width: 40,
                                decoration: BoxDecoration(color: capsuleColor, borderRadius: BorderRadius.circular(22)),
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(emoji, style: const TextStyle(fontSize: 22)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (item.value > 0)
                        Container(width: 4, height: 4,
                            decoration: BoxDecoration(color: isDark ? Colors.white : const Color(0xFF1D1B20), shape: BoxShape.circle))
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestAssessment(LatestAssessmentModel data) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(data.assessmentName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              height: 140, width: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: (data.percentage / 100.0).clamp(0.0, 1.0)),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value, strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      color: _getPercentageColor(data.percentage),
                    ),
                  ),
                  Center(
                    child: Text('${data.percentage}%',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
              child: Text(data.symptomLevel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                      color: _getPercentageColor(data.percentage))),
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
          child: Text(message,
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

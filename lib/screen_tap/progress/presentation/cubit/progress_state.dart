import 'package:ehnama3ak/screen_tap/progress/models/assessment_details_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/latest_assessment_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/mood_weekly_model.dart';

abstract class ProgressState {}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressSuccess extends ProgressState {
  final List<MoodWeeklyModel> moodWeekly;
  final LatestAssessmentModel? latestAssessment;
  final AssessmentDetailsModel? assessmentDetails;

  ProgressSuccess({
    required this.moodWeekly,
    this.latestAssessment,
    this.assessmentDetails,
  });
}

class ProgressError extends ProgressState {
  final String message;
  final bool isUnauthorized;

  ProgressError({required this.message, this.isUnauthorized = false});
}

class ProgressActionLoading extends ProgressState {}

class ProgressActionSuccess extends ProgressState {
  final String message;

  ProgressActionSuccess(this.message);
}

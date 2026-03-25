import 'package:ehnama3ak/screen_tap/progress/data/datasources/progress_api_service.dart';
import 'package:ehnama3ak/screen_tap/progress/models/assessment_details_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/latest_assessment_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/mood_weekly_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final ProgressApiService _progressApiService;

  ProgressCubit({required ProgressApiService progressApiService})
    : _progressApiService = progressApiService,
      super(ProgressInitial());

  Future<void> loadProgressData() async {
    emit(ProgressLoading());
    try {
      Future<LatestAssessmentModel?> fetchLatest() async {
        try {
          return await _progressApiService.getLatestAssessment();
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) return null;
          rethrow;
        }
      }

      Future<AssessmentDetailsModel?> fetchDetails() async {
        try {
          return await _progressApiService.getAssessmentDetails();
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) return null;
          rethrow;
        }
      }

      final responses = await Future.wait([
        _progressApiService.getMoodWeekly(),
        fetchLatest(),
        fetchDetails(),
      ]);

      final moodWeekly = responses[0] as List<MoodWeeklyModel>;
      final latestAssessment = responses[1] as LatestAssessmentModel?;
      final assessmentDetails = responses[2] as AssessmentDetailsModel?;

      emit(
        ProgressSuccess(
          moodWeekly: moodWeekly,
          latestAssessment: latestAssessment,
          assessmentDetails: assessmentDetails,
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(
          ProgressError(
            message: 'Unauthorized. Please login again.',
            isUnauthorized: true,
          ),
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        emit(ProgressError(message: 'Connection timeout. Please try again.'));
      } else {
        emit(
          ProgressError(
            message:
                'Server error: ${e.response?.statusCode ?? "Unknown error"}',
          ),
        );
      }
    } catch (e) {
      emit(ProgressError(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> saveMood(int value) async {
    emit(ProgressActionLoading());
    try {
      await _progressApiService.saveMood(value);
      emit(ProgressActionSuccess('Mood saved successfully!'));
      await loadProgressData();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(
          ProgressError(
            message: 'Unauthorized. Please login again.',
            isUnauthorized: true,
          ),
        );
      } else {
        emit(
          ProgressError(
            message: 'Failed (${e.response?.statusCode}): ${e.response?.data ?? e.message}',
          ),
        );
        await loadProgressData();
      }
    } catch (e) {
      emit(ProgressError(message: 'Unexpected error while saving mood.'));
      await loadProgressData();
    }
  }
}

import 'package:dio/dio.dart';
import 'package:ehnama3ak/screen_tap/progress/models/assessment_details_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/latest_assessment_model.dart';
import 'dart:developer';

import 'package:ehnama3ak/screen_tap/progress/models/mood_weekly_model.dart';
import 'package:ehnama3ak/screen_tap/progress/models/save_mood_model.dart';

class ProgressApiService {
  final Dio _dio;

  ProgressApiService({required Dio dio}) : _dio = dio;

  Future<List<MoodWeeklyModel>> getMoodWeekly() async {
    try {
      final response = await _dio.get('/api/Progress/mood-weekly');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => MoodWeeklyModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      log('DioError getting mood weekly: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error getting mood weekly: $e');
      rethrow;
    }
  }

  Future<LatestAssessmentModel> getLatestAssessment() async {
    try {
      final response = await _dio.get('/api/Progress/latest-assessment');
      return LatestAssessmentModel.fromJson(response.data);
    } on DioException catch (e) {
      log('DioError getting latest assessment: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error getting latest assessment: $e');
      rethrow;
    }
  }

  Future<AssessmentDetailsModel> getAssessmentDetails() async {
    try {
      final response = await _dio.get('/api/Progress/assessment-details');
      return AssessmentDetailsModel.fromJson(response.data);
    } on DioException catch (e) {
      log('DioError getting assessment details: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error getting assessment details: $e');
      rethrow;
    }
  }

  Future<void> saveMood(int value) async {
    try {
      final now = DateTime.now();
      final dayNames = {
        1: "Monday", 2: "Tuesday", 3: "Wednesday", 
        4: "Thursday", 5: "Friday", 6: "Saturday", 7: "Sunday"
      };
      final currentDay = dayNames[now.weekday] ?? "Monday";

      final model = SaveMoodModel(day: currentDay, value: value);
      await _dio.post('/api/Progress/mood', data: model.toJson());
    } on DioException catch (e) {
      log('DioError saving mood: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error saving mood: $e');
      rethrow;
    }
  }
}

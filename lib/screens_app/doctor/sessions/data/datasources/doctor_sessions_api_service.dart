import 'package:dio/dio.dart';
import 'package:ehnama3ak/screens_app/doctor/sessions/models/doctor_session_model.dart';
import 'dart:developer';

class DoctorSessionsApiService {
  final Dio _dio;

  DoctorSessionsApiService({required Dio dio}) : _dio = dio;

  /// GET all doctor sessions
  Future<List<DoctorSessionModel>> getDoctorSessions() async {
    return _fetchSessions('/api/DoctorSessions');
  }

  /// GET upcoming doctor sessions
  Future<List<DoctorSessionModel>> getUpcomingDoctorSessions() async {
    try {
      return await _fetchSessions('/api/DoctorSessions/upcoming');
    } catch (e) {
      log('Upcoming sessions failed, falling back to all sessions');
      // Fallback to all sessions if upcoming fails
      return await getDoctorSessions();
    }
  }

  Future<List<DoctorSessionModel>> _fetchSessions(String endpoint) async {
    try {
      log('Fetching sessions from: $endpoint');
      final response = await _dio.get(endpoint);

      log('Response status: ${response.statusCode}');
      log('Response data type: ${response.data.runtimeType}');
      log('Response data: ${response.data}');

      final dynamic data = response.data;

      if (data == null) return [];

      // If data is just a number (like '3'), it might be a count or an error
      if (data is num) {
        log(
          'Warning: Backend returned a number ($data) instead of sessions list',
        );
        return [];
      }

      // Handle simple list response
      if (data is List) {
        return data
            .map(
              (json) =>
                  DoctorSessionModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }

      // Handle response containing 'data' or 'items' keys
      if (data is Map) {
        final dynamic items = data['items'] ?? data['data'] ?? data['sessions'];
        if (items is List) {
          return items
              .map(
                (json) => DoctorSessionModel.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();
        }
        // If it's a single object, maybe it's one session
        return [DoctorSessionModel.fromJson(Map<String, dynamic>.from(data))];
      }

      return [];
    } on DioException catch (e) {
      log('DioError at $endpoint: ${e.response?.statusCode}');
      log('DioError data: ${e.response?.data}');

      // Temporary workaround for backend bug:
      // The API sometimes returns HTTP 500 with body "3"
      // which seems to be just a count / no-sessions indicator.
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      if (statusCode == 500 &&
          (responseData == 3 || responseData?.toString() == '3')) {
        log('Treating 500 with body "3" as empty sessions list');
        return [];
      }

      rethrow;
    } catch (e) {
      log('General Error at $endpoint: $e');
      rethrow;
    }
  }

  Future<bool> createDoctorSession({
    required String sessionType,
    required DateTime scheduledAt,
    double? price,
    String? videoUrl,
    String? audioUrl,
    String? pdfUrl,
    String? imageUrl,
    String? filePath,
    String? patientName,
    int patientId = 1, // Defaulting to 1 for now, should be passed from UI later
  }) async {
    // Map URL based on session type if not explicitly provided
    String? finalVideoUrl = videoUrl;
    String? finalAudioUrl = audioUrl;
    String? finalPdfUrl = pdfUrl;
    String? finalImageUrl = imageUrl;

    final Map<String, dynamic> data = {
      "SessionType": sessionType,
      "ScheduledAt": scheduledAt.toUtc().toIso8601String(),
      "Price": price ?? 0,
      "VideoUrl": finalVideoUrl ?? "",
      "AudioUrl": finalAudioUrl ?? "",
      "PdfUrl": finalPdfUrl ?? "",
      "ImageUrl": finalImageUrl ?? "",
    };

    final FormData formData = FormData.fromMap(data);

    if (filePath != null && filePath.isNotEmpty) {
      formData.files.add(MapEntry(
        "MediaFile",
        await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      ));
    }

    log('Creating session at: /api/DoctorSessions/$patientId with multipart/form-data');
    log('Fields: ${data.keys.join(', ')}');
    if (filePath != null) log('File: $filePath');

    try {
      final response = await _dio.post(
        '/api/DoctorSessions/$patientId',
        data: formData,
        options: Options(
          headers: {
            'accept': '*/*',
          },
        ),
      );

      log('Create response: ${response.statusCode} - ${response.data}');
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } on DioException catch (e) {
      log('DioError: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }
}

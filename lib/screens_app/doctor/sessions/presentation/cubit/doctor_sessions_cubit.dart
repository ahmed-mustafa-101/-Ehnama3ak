import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/screens_app/doctor/sessions/data/datasources/doctor_sessions_api_service.dart';
import 'package:ehnama3ak/features/auth/data/datasources/auth_api_service.dart';
import 'doctor_sessions_state.dart';

class DoctorSessionsCubit extends Cubit<DoctorSessionsState> {
  final DoctorSessionsApiService _apiService;

  DoctorSessionsCubit(this._apiService) : super(DoctorSessionsInitial());

  /// Fetch upcoming sessions (Primary for the sessions screen)
  Future<void> fetchUpcomingSessions() async {
    emit(DoctorSessionsLoading());
    try {
      final sessions = await _apiService.getUpcomingDoctorSessions();
      emit(DoctorSessionsLoaded(sessions));
    } catch (e) {
      emit(DoctorSessionsError(_mapError(e)));
    }
  }

  /// Fetch all sessions
  Future<void> fetchAllSessions() async {
    emit(DoctorSessionsLoading());
    try {
      final sessions = await _apiService.getDoctorSessions();
      emit(DoctorSessionsLoaded(sessions));
    } catch (e) {
      emit(DoctorSessionsError(_mapError(e)));
    }
  }

  Future<void> createSession({
    required String patientName,
    required String sessionType,
    required DateTime scheduledAt,
    double? price,
    String? sessionUrl,
    String? filePath,
  }) async {
    emit(DoctorSessionCreating());
    try {
      final success = await _apiService.createDoctorSession(
        patientName: patientName,
        sessionType: sessionType,
        scheduledAt: scheduledAt,
        price: price,
        sessionUrl: sessionUrl,
        filePath: filePath,
      );

      if (success) {
        emit(DoctorSessionCreateSuccess());
        // Default to refreshing upcoming sessions
        fetchUpcomingSessions();
      } else {
        emit(
          const DoctorSessionCreateError(
            "Failed to create session. Please check your data.",
          ),
        );
      }
    } catch (e) {
      emit(DoctorSessionCreateError(AuthApiService.parseApiError(e)));
    }
  }

  String _mapError(dynamic e) {
    return AuthApiService.parseApiError(e);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ehnama3ak/screen_tap/therapist/data/datasources/doctor_api_service.dart';
import 'package:ehnama3ak/screen_tap/therapist/presentation/cubit/doctor_state.dart';
import 'package:ehnama3ak/screen_tap/therapist/models/doctor_model.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorApiService _doctorApiService;

  DoctorCubit({required DoctorApiService doctorApiService})
      : _doctorApiService = doctorApiService,
        super(DoctorInitial());

  List<DoctorModel> _allDoctors = [];

  Future<void> loadDoctors() async {
    emit(DoctorLoading());
    try {
      final doctors = await _doctorApiService.getDoctors();
      _allDoctors = doctors;
      emit(DoctorSuccess(doctors));
    } on DioException catch (e) {
      _handleErrors(e);
    } catch (e) {
      emit(DoctorError(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> searchDoctors(String query) async {
    if (query.trim().isEmpty) {
      if (_allDoctors.isNotEmpty) {
        emit(DoctorSuccess(_allDoctors));
      } else {
        return loadDoctors();
      }
      return;
    }

    if (_allDoctors.isEmpty) {
      emit(DoctorLoading());
      try {
        _allDoctors = await _doctorApiService.getDoctors();
      } catch (e) {
        emit(DoctorError(message: 'Failed to search doctors: $e'));
        return;
      }
    }

    final queryLower = query.toLowerCase();
    final filteredDoctors = _allDoctors.where((doctor) {
      return doctor.name.toLowerCase().contains(queryLower) ||
          doctor.specialization.toLowerCase().contains(queryLower);
    }).toList();

    emit(DoctorSuccess(filteredDoctors));
  }

  Future<void> bookSession(int doctorId, String sessionDate, String sessionType) async {
    final currentState = state;
    emit(BookSessionLoading());
    try {
      await _doctorApiService.bookSession(doctorId, sessionDate, sessionType);
      emit(BookSessionSuccess('Session booked successfully'));
      
      // Restore doctors list state
      if (currentState is DoctorSuccess) {
        emit(DoctorSuccess(currentState.doctors));
      } else {
        await loadDoctors();
      }
    } on DioException catch (e) {
      final detail = e.response?.data;
      if (e.response?.statusCode == 401) {
        emit(DoctorError(message: 'Unauthorized. Please login again.', isUnauthorized: true));
      } else {
        emit(DoctorError(message: 'Failed (${e.response?.statusCode}): ${detail ?? e.message}'));
      }
      // Restore doctors list state
      if (currentState is DoctorSuccess) {
        emit(DoctorSuccess(currentState.doctors));
      } else {
        await loadDoctors();
      }
    } catch (e) {
      emit(DoctorError(message: 'Unexpected error while booking session.'));
      if (currentState is DoctorSuccess) {
        emit(DoctorSuccess(currentState.doctors));
      } else {
        await loadDoctors();
      }
    }
  }

  void _handleErrors(DioException e) {
    if (e.response?.statusCode == 401) {
      emit(DoctorError(message: 'Unauthorized. Please login again.', isUnauthorized: true));
    } else if (e.type == DioExceptionType.connectionTimeout || 
               e.type == DioExceptionType.receiveTimeout) {
      emit(DoctorError(message: 'Connection timeout. Please try again.'));
    } else {
      final detail = e.response?.data?.toString() ?? e.message;
      emit(DoctorError(message: 'Server error: ${e.response?.statusCode}\nDetails: $detail'));
    }
  }
}

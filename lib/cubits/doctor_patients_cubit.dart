import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/services/doctor_patients_api_service.dart';
import 'package:ehnama3ak/features/auth/data/datasources/auth_api_service.dart';
import 'doctor_patients_state.dart';

class DoctorPatientsCubit extends Cubit<DoctorPatientsState> {
  final DoctorPatientsApiService _apiService;
  Timer? _searchDebounce;

  DoctorPatientsCubit(this._apiService) : super(DoctorPatientsInitial());

  /// Fetch all patients
  Future<void> fetchPatients() async {
    emit(DoctorPatientsLoading());
    try {
      final patients = await _apiService.getDoctorPatients();
      emit(DoctorPatientsLoaded(patients));
    } catch (e) {
      emit(DoctorPatientsError(AuthApiService.parseApiError(e)));
    }
  }

  /// Search patients with debounce
  void searchPatients(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.trim().isEmpty) {
      fetchPatients();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      emit(DoctorPatientsSearching());
      try {
        final patients = await _apiService.searchDoctorPatients(query.trim());
        emit(DoctorPatientsLoaded(patients));
      } catch (e) {
        emit(DoctorPatientsError(AuthApiService.parseApiError(e)));
      }
    });
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}

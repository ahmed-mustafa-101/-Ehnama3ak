import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/doctor_reports_api_service.dart';
import '../features/auth/data/datasources/auth_api_service.dart';
import 'doctor_reports_state.dart';

class DoctorReportsCubit extends Cubit<DoctorReportsState> {
  final DoctorReportsApiService _apiService;

  DoctorReportsCubit(this._apiService) : super(DoctorReportsInitial());

  Future<void> fetchReports() async {
    emit(DoctorReportsLoading());
    try {
      final reports = await _apiService.getDoctorReports();
      emit(DoctorReportsLoaded(reports));
    } catch (e) {
      emit(DoctorReportsError(AuthApiService.parseApiError(e)));
    }
  }
}

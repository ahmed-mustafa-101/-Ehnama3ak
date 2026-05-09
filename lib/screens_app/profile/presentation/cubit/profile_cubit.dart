import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'package:ehnama3ak/core/storage/secure_token_storage.dart';
import 'package:ehnama3ak/screens_app/profile/data/datasources/profile_api_service.dart';
import 'package:ehnama3ak/screens_app/profile/models/profile_model.dart';
import 'package:ehnama3ak/screens_app/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileApiService _profileApiService;
  final SecureTokenStorage _tokenStorage;

  ProfileCubit({
    required ProfileApiService profileApiService,
    required SecureTokenStorage tokenStorage,
  })  : _profileApiService = profileApiService,
        _tokenStorage = tokenStorage,
        super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final apiProfile = await _profileApiService.getProfile();
      // Update cached profile image URL
      await _tokenStorage.saveUserProfileImageUrl(apiProfile.avatarUrl);

      // Get local active days count and merge it
      final localDaysCount = await PrefManager.getActiveDaysCount();
      
      // Reconstruct profile with local days count
      final profile = ProfileModel(
        fullName: apiProfile.fullName,
        email: apiProfile.email,
        avatarUrl: apiProfile.avatarUrl,
        sessionsCompleted: apiProfile.sessionsCompleted,
        exercisesCompleted: apiProfile.exercisesCompleted,
        activeDays: localDaysCount,
        age: apiProfile.age,
        gender: apiProfile.gender,
      );

      emit(ProfileSuccess(profile));
    } on DioException catch (e) {
      _handleErrors(e);
    } catch (e) {
      emit(ProfileError(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    int age = 0,
    String gender = '',
  }) async {
    final currentState = state;
    emit(UpdateProfileLoading());
    try {
      await _profileApiService.updateProfile(
        fullName: fullName,
        age: age,
        gender: gender,
      );
      emit(UpdateProfileSuccess('Profile updated successfully'));
      await loadProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(ProfileError(
            message: 'Unauthorized. Please login again.',
            isUnauthorized: true));
      } else {
        final detail = e.response?.data?.toString() ?? e.message;
        emit(ProfileError(
            message: 'Failed (${e.response?.statusCode}): $detail'));
      }
      if (currentState is ProfileSuccess) {
        emit(ProfileSuccess(currentState.profile));
      } else {
        await loadProfile();
      }
    } catch (e) {
      emit(ProfileError(message: 'Unexpected error while updating profile.'));
      if (currentState is ProfileSuccess) {
        emit(ProfileSuccess(currentState.profile));
      } else {
        await loadProfile();
      }
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    final currentState = state;
    emit(UpdateProfileLoading());
    try {
      await _profileApiService.updateProfileImage(imagePath);
      emit(UpdateProfileSuccess('Profile image updated successfully'));
      await loadProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(ProfileError(message: 'Unauthorized. Please login again.', isUnauthorized: true));
      } else {
        final detail = e.response?.data?.toString() ?? e.message;
        emit(ProfileError(message: 'Failed (${e.response?.statusCode}): $detail'));
      }
      if (currentState is ProfileSuccess) {
        emit(ProfileSuccess(currentState.profile));
      } else {
        await loadProfile();
      }
    } catch (e) {
      emit(ProfileError(message: 'Unexpected error while updating profile image.'));
      if (currentState is ProfileSuccess) {
        emit(ProfileSuccess(currentState.profile));
      } else {
        await loadProfile();
      }
    }
  }

  Future<void> loadSavedResources() async {
    final currentState = state;
    emit(SavedResourcesLoading());
    try {
      final resources = await _profileApiService.getSavedResources();
      emit(SavedResourcesSuccess(resources));
      
      // Usually, after viewing saved resources, we might want to keep the profile state active if we pop the view.
      // Or the UI can handle the state check. Since it's a separate full screen or dialog, returning to ProfileSuccess might be needed later.
      if (currentState is ProfileSuccess) {
         // To avoid immediately overwriting SavedResourcesSuccess before UI catches it, we hold it.
         // Wait, it might be better to just let UI catch SavedResourcesSuccess and then we revert.
         // Actually, typically Saved Resources is a separate screen entirely. Let's just keep the success state.
      }
    } on DioException catch (e) {
      _handleErrors(e);
    } catch (e) {
      emit(ProfileError(message: 'An unexpected error occurred: $e'));
    }
  }

  void resetToProfile() {
    loadProfile();
  }

  void _handleErrors(DioException e) {
    if (e.response?.statusCode == 401) {
      emit(ProfileError(message: 'Unauthorized. Please login again.', isUnauthorized: true));
    } else if (e.type == DioExceptionType.connectionTimeout || 
               e.type == DioExceptionType.receiveTimeout) {
      emit(ProfileError(message: 'Connection timeout. Please try again.'));
    } else {
      final detail = e.response?.data?.toString() ?? e.message;
      emit(ProfileError(message: 'Server error: ${e.response?.statusCode}\nDetails: $detail'));
    }
  }
}

import 'package:ehnama3ak/screens_app/profile/models/profile_model.dart';
import 'package:ehnama3ak/screens_app/profile/models/saved_resource_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileSuccess extends ProfileState {
  final ProfileModel profile;
  ProfileSuccess(this.profile);
}
class ProfileError extends ProfileState {
  final String message;
  final bool isUnauthorized;
  ProfileError({required this.message, this.isUnauthorized = false});
}

class UpdateProfileLoading extends ProfileState {}
class UpdateProfileSuccess extends ProfileState {
  final String message;
  UpdateProfileSuccess(this.message);
}

class SavedResourcesLoading extends ProfileState {}
class SavedResourcesSuccess extends ProfileState {
  final List<SavedResourceModel> resources;
  SavedResourcesSuccess(this.resources);
}

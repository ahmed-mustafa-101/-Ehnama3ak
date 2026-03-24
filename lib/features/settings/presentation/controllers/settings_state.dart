import 'package:equatable/equatable.dart';
import '../../data/models/settings_models.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final UserSettings? userSettings;
  final PrivacyPolicy? privacyPolicy;
  final SupportInfo? supportInfo;
  final String? errorMessage;
  final bool isUpdating;
  final bool isPasswordChanging;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.userSettings,
    this.privacyPolicy,
    this.supportInfo,
    this.errorMessage,
    this.isUpdating = false,
    this.isPasswordChanging = false,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    UserSettings? userSettings,
    PrivacyPolicy? privacyPolicy,
    SupportInfo? supportInfo,
    String? errorMessage,
    bool? isUpdating,
    bool? isPasswordChanging,
  }) {
    return SettingsState(
      status: status ?? this.status,
      userSettings: userSettings ?? this.userSettings,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      supportInfo: supportInfo ?? this.supportInfo,
      errorMessage: errorMessage, // Reset error if not provided
      isUpdating: isUpdating ?? this.isUpdating,
      isPasswordChanging: isPasswordChanging ?? this.isPasswordChanging,
    );
  }

  @override
  List<Object?> get props => [
        status,
        userSettings,
        privacyPolicy,
        supportInfo,
        errorMessage,
        isUpdating,
        isPasswordChanging,
      ];
}

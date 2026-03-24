import 'package:equatable/equatable.dart';
import 'package:ehnama3ak/core/models/user_role.dart';
import 'package:ehnama3ak/features/auth/data/models/auth_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  /// Full authenticated session (name, email, doctor fields, token, …).
  final AuthModel user;

  const AuthSuccess(this.user);

  UserRole get role => user.role;

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

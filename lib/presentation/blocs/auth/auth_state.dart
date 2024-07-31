part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final String token;

  const AuthSuccessState(this.token);
}

class AuthFailureState extends AuthState {
  final String error;

  const AuthFailureState(this.error);
}

final class UserAuthenticatedState extends AuthState {
  final String token;
  const UserAuthenticatedState(this.token);
  @override
  List<Object> get props => [token];
}

class UserUnauthenticatedState extends AuthState {}

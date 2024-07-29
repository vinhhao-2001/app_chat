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

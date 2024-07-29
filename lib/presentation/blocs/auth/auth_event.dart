part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginButtonEvent(this.username, this.password);

  @override
  List<Object> get props => [username, password];
}

class RegisterButtonEvent extends AuthEvent {
  final String fullName;
  final String username;
  final String password;
  final String confirmPassword;

  const RegisterButtonEvent(
      this.fullName, this.username, this.password, this.confirmPassword);

  @override
  List<Object> get props => [fullName, username, password, confirmPassword];
}

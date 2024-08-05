part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final String token;
  final String message;
  const AuthState({
    this.token = '',
    this.message = '',
  });

  AuthState copyWith({
    final String? token,
    final String? message,
  }) {
    return AuthState(
        token: token ?? this.token, message: message ?? this.message);
  }

  @override
  List<Object> get props => [token, message];
}

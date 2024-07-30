import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text.dart';
import '../../../data/data_sources/remote/api/api_service.dart';
import '../../../data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<LoginButtonEvent>(_onLoginButtonEvent);
    on<RegisterButtonEvent>(_onRegisterButtonEvent);
  }

  Future<void> _onLoginButtonEvent(
    LoginButtonEvent event,
    Emitter<AuthState> emit,
  ) async {
    String? errorMessage;
    if (event.username.isEmpty) {
      errorMessage = TextConstants.userNameEmpty;
    } else if (event.password.isEmpty) {
      errorMessage = TextConstants.passwordEmpty;
    }
    if (errorMessage != null) {
      emit(AuthFailureState(errorMessage));
      return;
    }

    emit(AuthLoadingState());

    try {
      final UserModel user = await ApiService()
          .login(event.username, event.password)
          .timeout(const Duration(seconds: 5));
      emit(AuthSuccessState(user.token));
    } catch (error) {
      if (error is TimeoutException) {
        emit(const AuthFailureState(TextConstants.internetError));
      } else {
        emit(AuthFailureState(error.toString()));
      }
    }
  }

  Future<void> _onRegisterButtonEvent(
    RegisterButtonEvent event,
    Emitter<AuthState> emit,
  ) async {
    String? errorMessage;

    if (event.fullName.isEmpty) {
      errorMessage = TextConstants.fullNameEmpty;
    } else if (event.username.isEmpty) {
      errorMessage = TextConstants.userNameEmpty;
    } else if (event.password.isEmpty) {
      errorMessage = TextConstants.passwordEmpty;
    } else if (event.confirmPassword.isEmpty) {
      errorMessage = TextConstants.confirmPasswordEmpty;
    } else if (event.password != event.confirmPassword) {
      errorMessage = TextConstants.passwordError;
    }

    if (errorMessage != null) {
      emit(AuthFailureState(errorMessage));
      return;
    }

    emit(AuthLoadingState());

    try {
      final UserModel user = await ApiService()
          .register(event.fullName, event.username, event.password)
          .timeout(const Duration(seconds: 5));
      emit(AuthSuccessState(user.token));
    } catch (error) {
      if (error is TimeoutException) {
        emit(const AuthFailureState(TextConstants.internetError));
      } else {
        emit(AuthFailureState(error.toString()));
      }
    }
  }
}

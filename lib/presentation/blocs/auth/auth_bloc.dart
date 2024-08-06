import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/utils/di.dart';

import '../../../domain/user_cases/auth_uc/check_user_use_case.dart';
import '../../../domain/user_cases/auth_uc/login_use_case.dart';
import '../../../domain/user_cases/auth_uc/logout_use_case.dart';
import '../../../domain/user_cases/auth_uc/register_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<LoginButtonEvent>(_onLoginButtonEvent);
    on<RegisterButtonEvent>(_onRegisterButtonEvent);
    on<CheckUserEvent>(_onCheckUser);
    on<LogoutEvent>(_onLogoutEvent);
  }

  Future<void> _onLoginButtonEvent(
    LoginButtonEvent event,
    Emitter<AuthState> emit,
  ) async {
    final loginUseCase = getIt<LoginUseCase>();
    String? errorMessage;
    if (event.username.isEmpty) {
      errorMessage = AppText.userNameEmpty;
    } else if (event.password.isEmpty) {
      errorMessage = AppText.passwordEmpty;
    }
    if (errorMessage != null) {
      emit(state.copyWith(message: errorMessage));
      return;
    }
    emit(state.copyWith(message: 'loading')); // auth loading

    try {
      final user = await loginUseCase
          .execute(event.username, event.password)
          .timeout(const Duration(seconds: 5));
      emit(state.copyWith(token: user.token, message: '')); // login success
    } catch (error) {
      if (error is TimeoutException) {
        emit(state.copyWith(message: AppText.internetError));
      } else {
        emit(state.copyWith(message: error.toString()));
      }
    }
  }

  Future<void> _onRegisterButtonEvent(
    RegisterButtonEvent event,
    Emitter<AuthState> emit,
  ) async {
    final registerUseCase = getIt<RegisterUseCase>();
    String? errorMessage;

    if (event.fullName.isEmpty) {
      errorMessage = AppText.fullNameEmpty;
    } else if (event.username.isEmpty) {
      errorMessage = AppText.userNameEmpty;
    } else if (event.password.isEmpty) {
      errorMessage = AppText.passwordEmpty;
    } else if (event.confirmPassword.isEmpty) {
      errorMessage = AppText.confirmPasswordEmpty;
    } else if (event.password != event.confirmPassword) {
      errorMessage = AppText.passwordError;
    }

    if (errorMessage != null) {
      emit(state.copyWith(message: errorMessage));
      return;
    }
    emit(state.copyWith()); // loading register
    try {
      final user = await registerUseCase
          .execute(event.fullName, event.username, event.password)
          .timeout(const Duration(seconds: 5));
      emit(state.copyWith(token: user.token)); // register success
    } catch (error) {
      if (error is TimeoutException) {
        emit(state.copyWith(message: AppText.internetError));
      } else {
        emit(state.copyWith(message: error.toString()));
      }
    }
  }

  Future<void> _onCheckUser(
      CheckUserEvent event, Emitter<AuthState> emit) async {
    // kiểm tra thông tin người dùng trong db
    final checkUser = getIt<CheckUserUseCase>();
    final user = await checkUser.execute();
    if (user != null) {
      emit(state.copyWith(token: user.token));
    } else {
      emit(state.copyWith());
    }
  }

  Future<void> _onLogoutEvent(
      LogoutEvent event, Emitter<AuthState> emit) async {
    // logout and delete token
    final logout = getIt<LogoutUseCase>();
    await logout.execute();
    emit(state.copyWith(token: '', message: ''));
  }
}

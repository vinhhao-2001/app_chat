import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/utils/di.dart';
import '../../../domain/user_cases/auth_uc/check_user_use_case.dart';
import '../../../domain/user_cases/auth_uc/login_use_case.dart';
import '../../../domain/user_cases/auth_uc/register_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<LoginButtonEvent>(_onLoginButtonEvent);
    on<RegisterButtonEvent>(_onRegisterButtonEvent);
    on<CheckUser>(_onCheckUser);
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
      emit(AuthFailureState(errorMessage));
      return;
    }

    emit(AuthLoadingState());

    try {
      final user = await loginUseCase
          .execute(event.username, event.password)
          .timeout(const Duration(seconds: 5));
      emit(AuthSuccessState(user.token));
    } catch (error) {
      if (error is TimeoutException) {
        emit(const AuthFailureState(AppText.internetError));
      } else {
        emit(AuthFailureState(error.toString()));
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
      emit(AuthFailureState(errorMessage));
      return;
    }

    emit(AuthLoadingState());

    try {
      final user = await registerUseCase
          .execute(event.fullName, event.username, event.password)
          .timeout(const Duration(seconds: 5));
      emit(AuthSuccessState(user.token));
    } catch (error) {
      if (error is TimeoutException) {
        emit(const AuthFailureState(AppText.internetError));
      } else {
        emit(AuthFailureState(error.toString()));
      }
    }
  }

  Future<void> _onCheckUser(CheckUser event, Emitter<AuthState> emit) async {
    // kiểm tra thông tin người dùng trong db
    final checkUser = getIt<CheckUserUseCase>();
    final user = await checkUser.execute();
    if (user != null) {
      emit(UserAuthenticatedState(user.token));
    } else {
      emit(UserUnauthenticatedState());
    }
  }
}

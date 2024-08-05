import 'dart:async';

import 'package:app_chat/core/theme/app_text.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/di.dart';
import '../../../domain/user_cases/shared_uc/load_avatar_use_case.dart';
import '../../../domain/user_cases/user_uc/get_user_use_case.dart';
import '../../../domain/user_cases/user_uc/update_user_use_case.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState()) {
    on<GetUserInfo>(_onGetUserInfo);
    on<UpdateUserInfo>(_onUpdateUserInfo);
  }

  void _onGetUserInfo(GetUserInfo event, Emitter<UserState> emit) async {
    emit(state.copyWith()); // loading
    final getUserUseCase = getIt<GetUserUseCase>();
    final loadAvatar = getIt<LoadAvatarUseCase>();
    try {
      final user = await getUserUseCase.execute(event.token);
      final avatarImage = await loadAvatar.execute(user.avatar);
      // emit thông tin người dùng
      emit(state.copyWith(
        userName: user.userName,
        fullName: user.fullName,
        avatarImage: avatarImage,
      ));
    } catch (e) {
      // trả về lỗi
      emit(state.copyWith(message: e.toString()));
    }
  }

  void _onUpdateUserInfo(UpdateUserInfo event, Emitter<UserState> emit) async {
    final updateUserUseCase = getIt<UpdateUserUseCase>();
    final oldState = state;
    try {
      if (state.userName.isNotEmpty) {
        // chỉ xử lý khi đã tải xong thông tin trong home
        final isSuccess = await updateUserUseCase
            .execute(event.token, event.newName, event.newAvatarPath)
            .timeout(const Duration(seconds: 5));
        if (isSuccess == true) {
          add(GetUserInfo(event.token));
        }
      }
    } catch (error) {
      if (error is TimeoutException) {
        emit(state.copyWith(
            userName: oldState.userName,
            fullName: oldState.fullName,
            avatarImage: oldState.avatarImage,
            message: AppText.internetError));
      } else {
        emit(state.copyWith(message: error.toString()));
      }
    }
  }
}

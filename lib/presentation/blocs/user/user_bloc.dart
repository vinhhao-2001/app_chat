import 'dart:async';

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
  UserBloc() : super(UserInitialState()) {
    on<GetUserInfo>(_onGetUserInfo);
    on<UpdateUserInfo>(_onUpdateUserInfo);
  }

  void _onGetUserInfo(GetUserInfo event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    final getUserUseCase = getIt<GetUserUseCase>();
    final loadAvatar = getIt<LoadAvatarUseCase>();

    try {
      // lấy thông tin người dùng
      final user = await getUserUseCase.execute(event.token);

      final avatarImage = await loadAvatar.execute(user.avatar);
      emit(UserLoadedState(
        userName: user.userName,
        fullName: user.fullName,
        avatar: user.avatar ?? '',
        avatarImage: avatarImage,
      ));
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }

  void _onUpdateUserInfo(UpdateUserInfo event, Emitter<UserState> emit) async {
    final updateUserUseCase = getIt<UpdateUserUseCase>();
    try {
      if (state is UserLoadedState) {
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
        // time out thì giữ nguyên trạng thái của home
        return;
      } else {
        emit(UserErrorState(error.toString()));
      }
    }
  }
}

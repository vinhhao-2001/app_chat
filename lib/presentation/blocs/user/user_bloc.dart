import 'dart:async';
import 'package:app_chat/data/data_sources/remote/api/api_service.dart';
import 'package:app_chat/data/data_sources/local/db_helper.dart';
import 'package:app_chat/data/models/user_model.dart';
import 'package:app_chat/domain/user_cases/user_uc/get_user_use_case.dart';
import 'package:app_chat/domain/user_cases/user_uc/update_user_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../data/data_mapper/user_data_mapper.dart';
import '../../../data/repositories_impl/user_repository_impl.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitialState()) {
    on<GetUserInfo>(_onGetUserInfo);
    on<UpdateUserInfo>(_onUpdateUserInfo);
    on<CheckUser>(_onCheckUser);
    on<Logout>(_onLogout);
  }

  void _onGetUserInfo(GetUserInfo event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    final apiService = ApiService();
    final userDataMapper = UserDataMapper();
    final repository = UserRepositoryImpl(apiService, userDataMapper);
    final getUserUseCase = GetUserUseCase(repository);
    try {
      // lấy thông tin người dùng
      final user = await getUserUseCase.execute(event.token);
      final avatarImage = await apiService.loadAvatar(user.avatar ?? '');
      emit(UserLoadedState(
        userName: user.userName,
        fullName: user.fullName,
        avatar: user.avatar ?? '',
        avatarImage: avatarImage,
      ));
    } catch (e) {
      // print(e);
      emit(UserErrorState(e.toString()));
    }
  }

  void _onUpdateUserInfo(UpdateUserInfo event, Emitter<UserState> emit) async {
    final apiService = ApiService();
    final userDataMapper = UserDataMapper();
    final repository = UserRepositoryImpl(apiService, userDataMapper);
    final updateUserUseCase = UpdateUserUseCase(repository);
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

  void _onLogout(Logout event, Emitter<UserState> emit) async {
    // xóa db và đăng xuất
    await DatabaseHelper().deleteDatabase();
    emit(UserLoggedOutState());
  }

  Future<void> _onCheckUser(CheckUser event, Emitter<UserState> emit) async {
    // kiểm tra thông tin người dùng trong db
    UserModel? user = await DatabaseHelper().getUser();
    if (user != null) {
      emit(UserAuthenticatedState(user.token));
    } else {
      emit(UserUnauthenticatedState());
    }
  }
}

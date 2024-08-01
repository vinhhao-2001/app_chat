import 'package:app_chat/presentation/blocs/picker/picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'data/data_mapper/friend_data_mapper.dart';
import 'data/data_mapper/message_data_mapper.dart';
import 'data/data_mapper/user_data_mapper.dart';

import 'data/data_sources/local/db_helper.dart';
import 'data/data_sources/remote/api/api_service.dart';

import 'data/repositories_impl/auth_repository_impl.dart';
import 'data/repositories_impl/friend_repository_impl.dart';
import 'data/repositories_impl/message_repository_impl.dart';
import 'data/repositories_impl/user_repository_impl.dart';

import 'domain/user_cases/auth_uc/check_user_use_case.dart';
import 'domain/user_cases/auth_uc/login_use_case.dart';
import 'domain/user_cases/auth_uc/logout_use_case.dart';
import 'domain/user_cases/auth_uc/register_use_case.dart';

import 'domain/user_cases/friend_uc/get_friend_list_use_case.dart';
import 'domain/user_cases/message_uc/get_message_list_use_case.dart';
import 'domain/user_cases/message_uc/reload_message_use_case.dart';
import 'domain/user_cases/message_uc/send_message_use_case.dart';
import 'domain/user_cases/shared_uc/load_avatar_use_case.dart';
import 'domain/user_cases/user_uc/get_user_use_case.dart';
import 'domain/user_cases/user_uc/update_user_use_case.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/friend/friend_bloc.dart';

import 'presentation/screens/splash_screen.dart';

GetIt getIt = GetIt.instance;
void main() {
  setupLocator();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (_) => UserBloc(),
        ),
        BlocProvider<FriendBloc>(
          create: (_) => FriendBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(),
        ),
        BlocProvider<PickerBloc>(
          create: (_) => PickerBloc(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    ),
  );
}

void setupLocator() {
  // api server
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // mapper
  getIt.registerLazySingleton<UserDataMapper>(() => UserDataMapper());

  getIt.registerLazySingleton<FriendDataMapper>(() => FriendDataMapper());

  getIt.registerLazySingleton<MessageDataMapper>(() => MessageDataMapper());

  // repository implement
  getIt.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl(
        getIt<ApiService>(),
        getIt<UserDataMapper>(),
      ));

  getIt.registerLazySingleton<UserRepositoryImpl>(() => UserRepositoryImpl(
        getIt<ApiService>(),
        getIt<UserDataMapper>(),
      ));

  getIt.registerLazySingleton<FriendRepositoryImpl>(() => FriendRepositoryImpl(
      getIt<ApiService>(), getIt<FriendDataMapper>(), getIt<DatabaseHelper>()));

  getIt.registerLazySingleton<MessageRepositoryImpl>(() =>
      MessageRepositoryImpl(getIt<ApiService>(), getIt<DatabaseHelper>(),
          getIt<MessageDataMapper>()));

  // use case
  getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepositoryImpl>()));

  getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRepositoryImpl>()));

  getIt.registerLazySingleton<CheckUserUseCase>(
      () => CheckUserUseCase(getIt<AuthRepositoryImpl>()));

  getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<DatabaseHelper>()));

  getIt.registerLazySingleton<GetUserUseCase>(
      () => GetUserUseCase(getIt<UserRepositoryImpl>()));

  getIt.registerLazySingleton<UpdateUserUseCase>(
      () => UpdateUserUseCase(getIt<UserRepositoryImpl>()));

  getIt.registerLazySingleton<GetFriendListUseCase>(
      () => GetFriendListUseCase(getIt<FriendRepositoryImpl>()));

  getIt.registerLazySingleton<GetMessageListUseCase>(
      () => GetMessageListUseCase(getIt<MessageRepositoryImpl>()));

  getIt.registerLazySingleton<ReloadMessageUseCase>(
      () => ReloadMessageUseCase(getIt<MessageRepositoryImpl>()));

  getIt.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(getIt<MessageRepositoryImpl>()));

  // shared
  getIt.registerLazySingleton<LoadAvatarUseCase>(
      () => LoadAvatarUseCase(getIt<ApiService>(), getIt<DatabaseHelper>()));
}

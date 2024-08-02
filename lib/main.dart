import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/picker/picker_bloc.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/friend/friend_bloc.dart';

import 'presentation/screens/splash_screen.dart';

import 'package:app_chat/core/utils/di.dart' as di;

void main() {
  di.configureInjection();
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

// void setupLocator() {
//   // api server
//   getIt.registerLazySingleton<ApiService>(() => ApiService());
//   getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
//
//   // mapper
//   getIt.registerLazySingleton<UserDataMapper>(() => UserDataMapper());
//
//   getIt.registerLazySingleton<FriendDataMapper>(() => FriendDataMapper());
//
//   getIt.registerLazySingleton<MessageDataMapper>(() => MessageDataMapper());
//
//   // repository implement
//   getIt.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl(
//         getIt<ApiService>(),
//         getIt<UserDataMapper>(),
//       ));
//
//   getIt.registerLazySingleton<UserRepositoryImpl>(() => UserRepositoryImpl(
//         getIt<ApiService>(),
//         getIt<UserDataMapper>(),
//       ));
//
//   getIt.registerLazySingleton<FriendRepositoryImpl>(() => FriendRepositoryImpl(
//       getIt<ApiService>(), getIt<FriendDataMapper>(), getIt<DatabaseHelper>()));
//
//   getIt.registerLazySingleton<MessageRepositoryImpl>(() =>
//       MessageRepositoryImpl(getIt<ApiService>(), getIt<DatabaseHelper>(),
//           getIt<MessageDataMapper>()));
//
//   // use case
//   getIt.registerLazySingleton<LoginUseCase>(
//       () => LoginUseCase(getIt<AuthRepositoryImpl>()));
//
//   getIt.registerLazySingleton<RegisterUseCase>(
//       () => RegisterUseCase(getIt<AuthRepositoryImpl>()));
//
//   getIt.registerLazySingleton<CheckUserUseCase>(
//       () => CheckUserUseCase(getIt<AuthRepositoryImpl>()));
//
//   getIt.registerLazySingleton<LogoutUseCase>(
//       () => LogoutUseCase(getIt<DatabaseHelper>()));
//
//   getIt.registerLazySingleton<GetUserUseCase>(
//       () => GetUserUseCase(getIt<UserRepositoryImpl>()));
//
//   getIt.registerLazySingleton<UpdateUserUseCase>(
//       () => UpdateUserUseCase(getIt<UserRepositoryImpl>()));
//
//   getIt.registerLazySingleton<GetFriendListUseCase>(
//       () => GetFriendListUseCase(getIt<FriendRepositoryImpl>()));
//
//   getIt.registerLazySingleton<GetMessageListUseCase>(
//       () => GetMessageListUseCase(getIt<MessageRepositoryImpl>()));
//
//   getIt.registerLazySingleton<ReloadMessageUseCase>(
//       () => ReloadMessageUseCase(getIt<MessageRepositoryImpl>()));
//
//   getIt.registerLazySingleton<SendMessageUseCase>(
//       () => SendMessageUseCase(getIt<MessageRepositoryImpl>()));
//
//   // shared
//   getIt.registerLazySingleton<LoadAvatarUseCase>(
//       () => LoadAvatarUseCase(getIt<ApiService>(), getIt<DatabaseHelper>()));
//
//   getIt.registerLazySingleton<LoadImageUseCase>(
//       () => LoadImageUseCase(getIt<ApiService>(), getIt<DatabaseHelper>()));
//
//   getIt.registerLazySingleton<DownloadFileUseCase>(
//       () => DownloadFileUseCase(getIt<ApiService>()));
//
//   getIt.registerLazySingleton<AddNicknameUseCase>(
//       () => AddNicknameUseCase(getIt<DatabaseHelper>()));
// }

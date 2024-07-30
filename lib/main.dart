import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'data/data_mapper/user_data_mapper.dart';
import 'data/data_sources/remote/api/api_service.dart';
import 'data/repositories_impl/auth_repository_impl.dart';
import 'domain/user_cases/auth_uc/login_use_case.dart';
import 'domain/user_cases/auth_uc/register_use_case.dart';
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
        BlocProvider<UserBloc>(
          create: (_) => UserBloc(),
        ),
        BlocProvider<FriendBloc>(
          create: (_) => FriendBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(),
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
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<UserDataMapper>(() => UserDataMapper());
  getIt.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl(
        getIt<ApiService>(),
        getIt<UserDataMapper>(),
      ));
  getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepositoryImpl>()));
  getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRepositoryImpl>()));
}

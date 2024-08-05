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

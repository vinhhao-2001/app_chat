import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_text.dart';
import '../blocs/auth/auth_bloc.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    bloc.add(CheckUserEvent());
    return Scaffold(
      body: Center(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.token.isNotEmpty) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => HomeScreen(token: state.token)),
              );
            } else if (state.token.isEmpty) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(
                size: 100,
              ),
              Text(
                AppText.appName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

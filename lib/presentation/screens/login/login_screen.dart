import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_text.dart';

import '../../blocs/auth/auth_bloc.dart';

import '../../widgets/widget.dart';

import '../home/home_screen.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _BodyLoginScreenState();
}

class _BodyLoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.token.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(token: state.token)),
          );
        } else if (state.message.isNotEmpty && state.message != 'loading') {
          AppDialog.showErrorMessageDialog(context, state.message);
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                AppText.appName,
              ),
              foregroundColor: Colors.blue,
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100),
                      const Text(
                        AppText.textUser,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextInputWidget(
                          textEditingController: _usernameController,
                          hintText: AppText.hintTextUser),
                      const SizedBox(height: 20),
                      const Text(
                        AppText.textPassword,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PasswordInputWidget(
                          textEditingController: _passwordController,
                          hintText: AppText.hintTextPassword),
                      const SizedBox(height: 100),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _authBloc.add(
                                LoginButtonEvent(
                                  _usernameController.text,
                                  _passwordController.text,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.buttonColor,
                            ),
                            child: const Text(
                              AppText.textLogin,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              AppText.textRegister,
                              style:
                                  TextStyle(color: AppColor.textRegisterColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.message == 'loading')
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: LoadingWidget(
                        size: 100,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_color.dart';
import '../../core/theme/app_text.dart';

import '../blocs/auth/auth_bloc.dart';

import '../widgets/widget.dart';

import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: BlocProvider(
          create: (context) => AuthBloc(),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailureState) {
                AppDialog.showErrorMessageDialog(context, state.error);
              } else if (state is AuthSuccessState) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HomeScreen(token: state.token)),
                );
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          child: const Text(
                            AppText.textCreateUser,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppText.textFullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextInputWidget(
                                    textEditingController: _fullNameController,
                                    hintText: AppText.hintTextFullName),
                                const SizedBox(height: 20),
                                const Text(
                                  AppText.textUser,
                                  style: TextStyle(
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                PasswordInputWidget(
                                    textEditingController: _passwordController,
                                    hintText: AppText.hintTextPassword),
                                const SizedBox(height: 20),
                                const Text(
                                  AppText.hintTextConfirmPassword,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                PasswordInputWidget(
                                    textEditingController:
                                        _confirmPasswordController,
                                    hintText: AppText.hintTextConfirmPassword),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    final fullName =
                                        _fullNameController.text.trim();
                                    final username =
                                        _usernameController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    final confirmPassword =
                                        _confirmPasswordController.text.trim();

                                    BlocProvider.of<AuthBloc>(context).add(
                                      RegisterButtonEvent(
                                        fullName,
                                        username,
                                        password,
                                        confirmPassword,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 40),
                                    backgroundColor: AppColor.buttonColor,
                                  ),
                                  child: const Text(
                                    AppText.textCreateUser,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state is AuthLoadingState)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: LoadingWidget(
                          size: 100,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

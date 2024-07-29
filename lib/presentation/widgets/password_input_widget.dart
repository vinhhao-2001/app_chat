import 'package:flutter/material.dart';

class PasswordInputWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;
  const PasswordInputWidget(
      {super.key, required this.textEditingController, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }
}

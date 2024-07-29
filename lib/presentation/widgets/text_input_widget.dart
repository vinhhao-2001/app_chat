import 'package:flutter/material.dart';

class TextInputWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hintText;

  const TextInputWidget(
      {super.key, required this.textEditingController, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/theme/text_constants.dart';

class AppDialog {
  static void showErrorMessageDialog(
      BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(errorMessage, textAlign: TextAlign.center),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              FocusScope.of(context).unfocus();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: ColorConstants.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            child: const Center(
              child: Text(TextConstants.textOk, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

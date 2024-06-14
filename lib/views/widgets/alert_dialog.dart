import 'package:flutter/material.dart';

class CustomAlertDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String message = '',
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: message.isNotEmpty ? Text(message) : null,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true if Yes is pressed
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false if No is pressed
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

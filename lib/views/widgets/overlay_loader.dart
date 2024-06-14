import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class LoadingOverlay {
  static Future<void> show(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _LoadingOverlayDialog();
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class _LoadingOverlayDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with blur effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color:
                  Colors.black.withOpacity(0.5), // Adjust the opacity as needed
            ),
          ),
        ),
        // Centered CircularProgressIndicator
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
      ],
    );
  }
}

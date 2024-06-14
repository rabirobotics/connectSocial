import 'package:flutter/material.dart';

snack(BuildContext context, String title, Color color) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      title,
      style: const TextStyle(color: Colors.black),
    ),
    backgroundColor: color,
  ));
}

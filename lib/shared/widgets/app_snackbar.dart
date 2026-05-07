import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  _showSnackBar(
    context,
    message,
    const Color(0xFF1D9E75),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  _showSnackBar(
    context,
    message,
    const Color(0xFFC62828),
  );
}

void showSuccess(BuildContext context, String message) {
  showSuccessSnackBar(context, message);
}

void showError(BuildContext context, String message) {
  showErrorSnackBar(context, message);
}

void _showSnackBar(
  BuildContext context,
  String message,
  Color backgroundColor,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

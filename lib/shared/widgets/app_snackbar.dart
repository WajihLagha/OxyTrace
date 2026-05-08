import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.success, Icons.check_circle, 3);
}

void showErrorSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.danger, Icons.error, 4);
}

void showInfoSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.info, Icons.info, 3);
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
  IconData icon,
  int seconds,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: seconds),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
}

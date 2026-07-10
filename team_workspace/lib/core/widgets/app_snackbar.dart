import 'package:flutter/material.dart';

enum AppSnackBarType { success, error }

class AppSnackBar {
  /// Shows a SnackBar with styling depending on [type]. Returns the
  /// [ScaffoldFeatureController] so callers can await `.closed` if needed.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.success,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    final backgroundColor =
        type == AppSnackBarType.success ? Colors.green : Colors.red;

    final snack = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
    );

    return ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}


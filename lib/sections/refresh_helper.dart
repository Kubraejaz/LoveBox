import 'package:flutter/material.dart';
import '../utils/snackbar_helper.dart';

class RefreshHelper {
  static Future<void> refreshProducts({
    required BuildContext context,
    required Future<void> Function() refreshFunction,
  }) async {
    try {
      SnackbarHelper.showInfo(context, "Refreshing products...");
      await refreshFunction();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      SnackbarHelper.showError(context, "Failed to refresh: $e");
    }
  }
}

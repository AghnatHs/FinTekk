import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> globalSnackbarKey =
    GlobalKey<ScaffoldMessengerState>();

void pushGlobalSnackbar({
  required String message,
  Duration duration = const Duration(seconds: 1),
}) {
  final SnackBar snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  );
  globalSnackbarKey.currentState?.clearSnackBars();
  globalSnackbarKey.currentState?.showSnackBar(snackBar);
}

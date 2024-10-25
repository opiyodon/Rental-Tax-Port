import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static Future<void> handleFutureError<T>(
      BuildContext context,
      Future<T> Function() future,
      String errorMessage,
      ) async {
    try {
      await future();
    } catch (e) {
      showError(context, '$errorMessage: $e');
    }
  }

  static Widget handleStreamError<T>(
      Stream<T> stream,
      Widget Function(T data) builder,
      ) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return builder(snapshot.data as T);
      },
    );
  }
}
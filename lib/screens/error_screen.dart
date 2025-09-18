import 'package:flutter/material.dart';

enum ErrorType { noInternet, supabaseError, generalError }

class ErrorScreen extends StatelessWidget {
  final ErrorType errorType;
  final String message;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.errorType,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(errorType),
              color: _getColor(errorType),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(ErrorType type) {
    switch (type) {
      case ErrorType.noInternet:
        return Icons.wifi_off;
      case ErrorType.supabaseError:
        return Icons.cloud_off;
      case ErrorType.generalError:
        return Icons.error_outline;
    }
  }

  Color _getColor(ErrorType type) {
    switch (type) {
      case ErrorType.noInternet:
        return Colors.orange;
      case ErrorType.supabaseError:
        return Colors.red;
      case ErrorType.generalError:
        return Colors.grey;
    }
  }
}

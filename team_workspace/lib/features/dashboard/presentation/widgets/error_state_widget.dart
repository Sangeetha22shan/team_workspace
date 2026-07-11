import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? code;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    Key? key,
    required this.message,
    this.code,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOfflineError = message.contains('internet') || message.contains('offline');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOfflineError ? Icons.cloud_off : Icons.error_outline,
            size: 80,
            color: isOfflineError ? Colors.orange : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          if (onRetry != null && !isOfflineError) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}


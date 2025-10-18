import 'package:flutter/material.dart';
import 'package:firebase_nexus/appColors.dart';

class LoadingScreens extends StatelessWidget {
  final String message;
  final bool error;
  final VoidCallback? onRetry;

  const LoadingScreens({
    super.key,
    required this.message,
    this.error = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!error)
              const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.brown,
              ),
            ),
            if (error && onRetry != null)
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: onRetry,
                  child: const Text('Go Back'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

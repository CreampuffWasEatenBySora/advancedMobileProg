import 'package:flutter/material.dart';
import 'package:firebase_nexus/appColors.dart';

class LoadingOverlay {
  static bool _isVisible = false;

  static void show(BuildContext context, {String message = 'Loading...'}) {
    if (_isVisible) return; // prevent stacking multiple overlays
    _isVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false, // prevent closing by tapping outside
      barrierColor: Colors.black.withOpacity(0.3), // dim background
      builder: (_) => _FloatingLoader(message: message), // no const here
    );
  }

  static void hide(BuildContext context) {
    if (_isVisible) {
      Navigator.of(context, rootNavigator: true).pop();
      _isVisible = false;
    }
  }
}

class _FloatingLoader extends StatelessWidget {
  final String message;

  const _FloatingLoader({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

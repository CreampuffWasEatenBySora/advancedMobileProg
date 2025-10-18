import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your ConfirmationModal
// import 'confirmation_modal.dart';

enum ConfirmationModalType {
  cancel,
  delete,
  success,
}

class ConfirmationModal extends StatelessWidget {
  final ConfirmationModalType type;
  final String? title;
  final String? message;
  final String? confirmButtonText;
  final VoidCallback? onConfirm;

  const ConfirmationModal({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.confirmButtonText,
    this.onConfirm,
  });

  Map<String, dynamic> _getConfig() {
    switch (type) {
      case ConfirmationModalType.cancel:
        return {
          'icon': Icons.cancel_rounded,
          'iconColor': const Color(0xFFFF9800),
          'title': title ?? 'Cancel Order',
          'message': message ??
              'Are you sure you want to cancel this order? This action cannot be undone.',
          'confirmText': confirmButtonText ?? 'Yes, Cancel',
          'confirmColor': const Color(0xFFFF9800),
        };
      case ConfirmationModalType.delete:
        return {
          'icon': Icons.delete_forever_rounded,
          'iconColor': Colors.redAccent,
          'title': title ?? 'Delete Product',
          'message': message ??
              'Are you sure you want to delete this product? This action cannot be undone.',
          'confirmText': confirmButtonText ?? 'Delete',
          'confirmColor': Colors.redAccent,
        };
      case ConfirmationModalType.success:
        return {
          'icon': Icons.check_circle_rounded,
          'iconColor': const Color(0xFF4CAF50),
          'title': title ?? 'Success!',
          'message': message ?? 'Your action was completed successfully.',
          'confirmText': confirmButtonText ?? 'OK',
          'confirmColor': const Color(0xFF4CAF50),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final bool isSuccessType = type == ConfirmationModalType.success;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config['icon'],
              color: config['iconColor'],
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              config['title'],
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: config['iconColor'],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              config['message'],
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                color: const Color(0xFF4B2E19),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onConfirm != null) {
                    onConfirm!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: config['confirmColor'],
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  config['confirmText'],
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isSuccessType) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

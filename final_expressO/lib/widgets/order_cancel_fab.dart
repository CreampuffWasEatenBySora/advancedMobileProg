import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'confirm_modal.dart'; // Import your ConfirmationModal

class CancelOrderFab extends StatelessWidget {
  final String orderStatus;
  final String? orderId; // Optional order ID for display in messages
  final VoidCallback onCancel;

  const CancelOrderFab({
    super.key,
    required this.orderStatus,
    this.orderId,
    required this.onCancel,
  });

  bool get _canCancel => orderStatus.toLowerCase() == 'Pending';

  @override
  Widget build(BuildContext context) {
    // Only show if status is "Pending"
    if (!_canCancel) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ConfirmationModal(
                type: ConfirmationModalType.cancel,
                onConfirm: () {
                  // Execute the cancel callback
                  onCancel();

                  // Show success modal after a short delay
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationModal(
                          type: ConfirmationModalType.success,
                          title: 'Order Cancelled',
                          message: orderId != null
                              ? 'Order $orderId has been cancelled successfully.'
                              : 'Your order has been cancelled successfully.',
                          onConfirm: () {
                            // Close the order detail page after success
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      );
                    }
                  });
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            'Cancel Order',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

typedef ApproveCallback = void Function(String remarks);

class ApproveModal extends StatefulWidget {
  final ApproveCallback onConfirm;
  const ApproveModal({super.key, required this.onConfirm});

  @override
  State<ApproveModal> createState() => _ApproveModalState();
}

class _ApproveModalState extends State<ApproveModal> {
  final TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Approve Order?',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirm and approve this order for processing',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              color: Color(0xFF8E4B0E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Remarks (Optional)',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF38241D),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any notes here...',
              hintStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE7D3B4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF8E4B0E)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF8E4B0E),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String remarks = remarksController.text.trim();
            widget.onConfirm(remarks);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// AlertDialog(
//       title: const Text('Approve Order?'),
//       content: const Text('Confirm and approve this order for processing.'),
//       actions: [
//         TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel')),
//         ElevatedButton(onPressed: widget.onConfirm, child: const Text('Yes')),
//       ],
//     );

class RejectModal extends StatefulWidget {
  final ApproveCallback onConfirm;
  const RejectModal({super.key, required this.onConfirm});

  @override
  State<RejectModal> createState() => _RejectModalState();
}

class _RejectModalState extends State<RejectModal> {
  final TextEditingController reasonController = TextEditingController();

  final TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.cancel, color: Color(0xFFE53E3E), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Reject Order?',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will reject the customer\'s order and stop it from being processed.',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: Color(0xFF8E4B0E),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reason *',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF38241D),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason for rejection...',
                hintStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE7D3B4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8E4B0E)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Remarks (Optional)',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF38241D),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: remarksController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add any notes here...',
                hintStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE7D3B4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8E4B0E)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF8E4B0E),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String reason = reasonController.text.trim();
            String remarks = remarksController.text.trim();

            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please provide a reason for rejection'),
                  backgroundColor: Color(0xFFE53E3E),
                ),
              );
              return;
            }

            // Combine reason and remarks with separator
            String combinedNotes =
                remarks.isEmpty ? reason : '$reason - $remarks';

            widget.onConfirm(remarks);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53E3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class CancelModal extends StatefulWidget {
  final ApproveCallback onConfirm;
  const CancelModal({super.key, required this.onConfirm});

  @override
  State<CancelModal> createState() => _CancelModalState();
}

class _CancelModalState extends State<CancelModal> {
  final TextEditingController reasonController = TextEditingController();

  final TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.cancel, color: Color(0xFFE53E3E), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cancel Order?',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will cancel your order and stop it from being processed. \nNote: Frequent cancellation is frowned upon!',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: Color(0xFF8E4B0E),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reason *',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF38241D),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation...',
                hintStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE7D3B4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8E4B0E)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Remarks (Optional)',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF38241D),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: remarksController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add any notes here...',
                hintStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE7D3B4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF8E4B0E)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF8E4B0E),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String reason = reasonController.text.trim();
            String remarks = remarksController.text.trim();

            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please provide a reason for the cancellation'),
                  backgroundColor: Color(0xFFE53E3E),
                ),
              );
              return;
            }

            // Combine reason and remarks with separator
            String combinedNotes =
                remarks.isEmpty ? reason : '$reason - $remarks';

            widget.onConfirm(remarks);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53E3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class NextStatusModal extends StatefulWidget {
  final String currentStatus;
  // final String deliveryMethod;
  final Function(String nextStatus, String remarks) onConfirm;

  const NextStatusModal({
    super.key,
    required this.currentStatus,
    // required this.deliveryMethod,
    required this.onConfirm,
  });

  @override
  State<NextStatusModal> createState() => _NextStatusModalState();
}

class _NextStatusModalState extends State<NextStatusModal> {
  String _getNextStatus() {
    final status = widget.currentStatus.toLowerCase();
    if (status == 'processing') {
      // return method == 'walk-in' ? 'Ready to Pickup' : 'For Delivery';
      return 'Ready to Pickup';
    } else if (status == 'ready to pickup') {
      return 'Completed';
    }
    return 'Processing';
  }

  final TextEditingController remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String title = '';
    String description = '';
    IconData icon = Icons.arrow_forward;
    Color iconColor = const Color(0xFF2196F3);

    final nextStatus = _getNextStatus();
    // Determine modal content based on next status
    if (nextStatus == 'For Delivery') {
      title = 'Ready for Delivery?';
      description = 'Mark this order as ready for delivery to the customer';
      icon = Icons.local_shipping;
      iconColor = const Color(0xFF2196F3);
    } else if (nextStatus == 'Ready to Pickup') {
      title = 'Ready to Pickup?';
      description = 'Mark this order as ready for customer pickup';
      icon = Icons.store;
      iconColor = const Color(0xFFFF9800);
    } else if (nextStatus == 'Completed') {
      title = 'Complete Order?';
      description = 'Mark this order as completed';
      icon = Icons.check_circle;
      iconColor = const Color(0xFF4CAF50);
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              color: Color(0xFF8E4B0E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Remarks (Optional)',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF38241D),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: remarksController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any notes here...',
              hintStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE7D3B4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF8E4B0E)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF8E4B0E),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String remarks = remarksController.text.trim();
            widget.onConfirm(nextStatus, remarks);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: iconColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Yes',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

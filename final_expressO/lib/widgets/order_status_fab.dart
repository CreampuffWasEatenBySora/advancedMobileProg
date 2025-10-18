// Save this as: lib/widgets/order_status_fab.dart

import 'package:flutter/material.dart';

class OrderStatusFab extends StatefulWidget {
  final String currentStatus;
  final String deliveryMethod; // 'Walk-in' or 'Delivery'
  final Function(String, String) onStatusChanged; // status, remarks

  const OrderStatusFab({
    Key? key,
    required this.currentStatus,
    required this.deliveryMethod,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<OrderStatusFab> createState() => _OrderStatusFabState();
}

class _OrderStatusFabState extends State<OrderStatusFab>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String status = widget.currentStatus.toLowerCase();

    // Don't show FAB for terminal statuses
    bool isTerminalStatus =
        status == 'cancelled' || status == 'rejected' || status == 'completed';

    if (isTerminalStatus) {
      return const SizedBox.shrink();
    }

    bool isForApproval = status == 'Pending';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action Buttons (appear when expanded)
        if (_isFabExpanded) ...[
          if (isForApproval) ...[
            // Approve Button (Green Check)
            AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimationController.value,
                  child: FloatingActionButton(
                    onPressed: () {
                      _showApprovalModal();
                    },
                    backgroundColor: const Color(0xFF4CAF50),
                    heroTag: "approve",
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Reject Button (Red X)
            AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimationController.value,
                  child: FloatingActionButton(
                    onPressed: () {
                      _showRejectModal();
                    },
                    backgroundColor: const Color(0xFFE53E3E),
                    heroTag: "reject",
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ] else ...[
            // Next Status Button (Plus) - For Processing or For Delivery
            AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimationController.value,
                  child: FloatingActionButton(
                    onPressed: () {
                      _showNextStatusModal();
                    },
                    backgroundColor: const Color(0xFFE27D19),
                    heroTag: "next",
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _isFabExpanded = !_isFabExpanded;
              if (_isFabExpanded) {
                _fabAnimationController.forward();
              } else {
                _fabAnimationController.reverse();
              }
            });
          },
          backgroundColor: const Color(0xFFE27D19),
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isFabExpanded ? Icons.close : Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Get next status based on current status and delivery method
  String _getNextStatus() {
    String status = widget.currentStatus.toLowerCase();
    String method = widget.deliveryMethod.toLowerCase();


  
    if (status == 'processing') {
      return method == 'walk-in' ? 'Ready to Pickup' : 'For Delivery';
    } else if (status == 'for delivery' || status == 'ready to pickup') {
      return 'Completed';
    }
    return 'Processing';
  }

  // Modal Pending (Pending -> Processing)
  void _showApprovalModal() {
    _closeFab();
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                remarksController.dispose();
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
                remarksController.dispose();
                Navigator.of(context).pop();
                widget.onStatusChanged('Processing', remarks);
                _showSnackbar(
                    'Order approved successfully!', const Color(0xFF4CAF50));
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
      },
    );
  }

  // Modal for Rejection
  void _showRejectModal() {
    _closeFab();
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                reasonController.dispose();
                remarksController.dispose();
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

                reasonController.dispose();
                remarksController.dispose();
                Navigator.of(context).pop();
                widget.onStatusChanged('Rejected', combinedNotes);
                _showSnackbar(
                    'Order has been rejected', const Color(0xFFE53E3E));
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
      },
    );
  }

  // Modal for Next Status (Processing -> For Delivery/Ready to Pickup -> Completed)
  void _showNextStatusModal() {
    _closeFab();
    final TextEditingController remarksController = TextEditingController();
    String nextStatus = _getNextStatus();
    String title = '';
    String description = '';
    IconData icon = Icons.arrow_forward;
    Color iconColor = const Color(0xFF2196F3);

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

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                remarksController.dispose();
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
                remarksController.dispose();
                Navigator.of(context).pop();
                widget.onStatusChanged(nextStatus, remarks);
                _showSnackbar('Order status updated to $nextStatus', iconColor);
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
      },
    );
  }

  // Helper to close FAB
  void _closeFab() {
    setState(() {
      _isFabExpanded = false;
      _fabAnimationController.reverse();
    });
  }

  // Helper to show snackbar
  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

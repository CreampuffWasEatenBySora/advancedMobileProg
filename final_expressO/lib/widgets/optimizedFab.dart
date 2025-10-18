import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/widgets/statusFabModals.dart';
import 'package:flutter/material.dart';

class OrderStatusFabOptimized extends StatefulWidget {
  final String currentStatus;
  final String deliveryMethod;
  final int orderID;
  final bool loading;
  final VoidCallback onStatusChanged;

  const OrderStatusFabOptimized({
    Key? key,
    required this.currentStatus,
    required this.orderID,
    required this.loading,
    required this.deliveryMethod,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<OrderStatusFabOptimized> createState() =>
      _OrderStatusFabOptimizedState();
}

class _OrderStatusFabOptimizedState extends State<OrderStatusFabOptimized>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _fabLoading = false;
  late AnimationController _fabAnimationController;
  final supabaseHelper = AdminSupabaseHelper();

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

  Future<void> _updateOrderStatus(String status, String remarks) async {
    if (_fabLoading) return; // Prevent spamming

    setState(() {
      _fabLoading = true;
    });

    try {
      final checkIfCancelable =
          await supabaseHelper.getById('Orders', 'id', widget.orderID);

      print('checkIfCancelable');
      print(checkIfCancelable);

      if (checkIfCancelable != null) {
        final status = checkIfCancelable['Status']?.toString().toLowerCase();

        // Only allow cancelation if still pending or processing
        final alreadyCancelled = status == 'cancelled';

        if (alreadyCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You cannot cancel a "$status" order!'),
              backgroundColor: Colors.red,
            ),
          );

          setState(() {
            _isFabExpanded = false;
          });

          // Stop here since it’s not cancelable
          widget.onStatusChanged();
          return;
        }

        // Add a short delay before triggering refresh
        // await Future.delayed(const Duration(milliseconds: 300));
      }

      print("Updating order ${widget.orderID} to: $status");

      final result = await supabaseHelper.insert('Order_updates', {
        'order_id': widget.orderID,
        'status': status,
        'remarks': remarks,
      });

      final result2 = await supabaseHelper
          .update('Orders', 'id', widget.orderID.toString(), {
        'Status': status,
      });

      if (result['status'] == 'success' && result2['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order updated to $status'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isFabExpanded = false;
        });

        // Notify parent
        widget.onStatusChanged();
      } else {
        // Database-level error (like constraint violation or network fail)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update order: ${result['message']}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Runtime error handling (unexpected exceptions)
      print("Unexpected error updating order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _fabLoading = false;
      });
    }
  }

  // Figure out which modal to show
  void _showModalForStatus() {
    String status = widget.currentStatus.toLowerCase();
    if (status == 'pending') {
      _showApprovalModal();
    } else if (status == 'processing' ||
        status == 'for delivery' ||
        status == 'ready to pickup') {
      _showNextStatusModal();
    }
  }

  void _showApprovalModal() {
    showDialog(
      context: context,
      builder: (dialogContext) => ApproveModal(onConfirm: (String remarks) {
        Navigator.pop(dialogContext);
        _updateOrderStatus('Processing', remarks);
      }),
    );
  }

  void _showRejectModal() {
    showDialog(
      context: context,
      builder: (dialogContext) => RejectModal(onConfirm: (String remarks) {
        Navigator.pop(dialogContext);
        _updateOrderStatus('Rejected', remarks);
      }),
    );
  }

  void _showNextStatusModal() {
    showDialog(
      context: context,
      builder: (dialogContext) => NextStatusModal(
        currentStatus: widget.currentStatus,
        // deliveryMethod: widget.deliveryMethod,
        onConfirm: (nextStatus, remarks) {
          Navigator.pop(dialogContext);
          _updateOrderStatus(nextStatus, remarks);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String status = widget.currentStatus.toLowerCase();
    bool isTerminal = ['cancelled', 'rejected', 'completed'].contains(status);

    if (isTerminal) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFabExpanded) ...[
          if (status == 'pending') ...[
            FloatingActionButton(
              backgroundColor: const Color(0xFF4CAF50),
              onPressed: _showApprovalModal,
              heroTag: 'approve',
              child: const Icon(Icons.check),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              backgroundColor: const Color(0xFFE53E3E),
              onPressed: _showRejectModal,
              heroTag: 'reject',
              child: const Icon(Icons.close),
            ),
          ] else ...[
            FloatingActionButton(
              backgroundColor: const Color(0xFFE27D19),
              onPressed: _showNextStatusModal,
              heroTag: 'next',
              child: const Icon(Icons.arrow_forward),
            ),
          ],
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          backgroundColor: _fabLoading ? Colors.grey : const Color(0xFFE27D19),
          onPressed: _fabLoading
              ? null
              : () {
                  setState(() {
                    _isFabExpanded = !_isFabExpanded;
                    if (_isFabExpanded) {
                      _fabAnimationController.forward();
                    } else {
                      _fabAnimationController.reverse();
                    }
                  });
                },
          child: _fabLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : AnimatedRotation(
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
}

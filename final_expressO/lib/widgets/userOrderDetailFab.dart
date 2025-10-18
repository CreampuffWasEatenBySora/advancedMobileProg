import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/widgets/statusFabModals.dart';
import 'package:flutter/material.dart';

class UserOrderStatusFabOptimized extends StatefulWidget {
  final String currentStatus;
  final int orderID;
  final bool loading;
  final VoidCallback onStatusChanged;

  const UserOrderStatusFabOptimized({
    Key? key,
    required this.currentStatus,
    required this.orderID,
    required this.loading,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<UserOrderStatusFabOptimized> createState() =>
      _UserOrderStatusFabOptimizedState();
}

class _UserOrderStatusFabOptimizedState
    extends State<UserOrderStatusFabOptimized>
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

    bool isCancelable = true;

    try {
      final checkIfCancelable =
          await supabaseHelper.getById('Orders', 'id', widget.orderID);

      print('checkIfCancelable');
      print(checkIfCancelable);

      if (checkIfCancelable != null) {
        final status = checkIfCancelable['Status']?.toString().toLowerCase();

        // Only allow cancelation if still pending or processing
        final isCancelable = status == 'pending' || status == 'processing';
        final alreadyRejected = status == 'rejected';

        if (!isCancelable && !alreadyRejected) {
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

  void _showCancelModal() {
    showDialog(
      context: context,
      builder: (dialogContext) => CancelModal(onConfirm: (String remarks) {
        Navigator.pop(dialogContext);
        _updateOrderStatus('Cancelled', remarks);
      }),
    );
  }

  void _notifyInability() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You can only cancel an order up to when it\'s still processing!',
        ),
        backgroundColor: Colors.red,
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
          FloatingActionButton(
            backgroundColor: const Color(0xFFE53E3E),
            onPressed: status == 'pending' || status == 'processing'
                ? _showCancelModal
                : _notifyInability,
            heroTag: 'reject',
            child: const Icon(Icons.close),
          ),
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

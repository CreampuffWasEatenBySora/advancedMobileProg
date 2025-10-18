import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/models/order.dart';
import 'package:firebase_nexus/widgets/loading_screens.dart';
import 'package:firebase_nexus/widgets/optimizedFab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../widgets/order_status_fab.dart';

class AdminOrderDetailedPage extends StatefulWidget {
  final Order order;
  final Product product;
  final String orderStatus;

  const AdminOrderDetailedPage({
    super.key,
    required this.order,
    required this.product,
    this.orderStatus = 'Processing',
  });

  @override
  State<AdminOrderDetailedPage> createState() => _AdminOrderDetailedPageState();
}

class _AdminOrderDetailedPageState extends State<AdminOrderDetailedPage>
    with TickerProviderStateMixin {
  String _currentStatus = 'Pending';
  String _deliveryMethod = 'Walk-in'; // or get from order data
  bool _isCustomerInfoExpanded = true;
  bool _isOrderItemsExpanded = true;
  bool _isTimelineExpanded = true;
  bool _loading = false;
  bool _isPaymentDetailsExpanded = true;

  double _discount = 0;

  late List<Map<String, dynamic>> _updates = [];
  // double get totalPayment => (widget.order.totalPrice + 50) - _discount;
  double get totalPayment => (widget.order.totalPrice) - _discount;

  final supabaseHelper = AdminSupabaseHelper();
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _currentStatus = widget.orderStatus;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, dynamic>? hasStatus(String status) {
    Map<String, dynamic>? fetchedElement;

    try {
      fetchedElement = _updates.firstWhere(
        (update) =>
            update['status'].toString().toLowerCase() == status.toLowerCase(),
      );
    } catch (e) {
      // firstWhere throws if no match found
      fetchedElement = null;
    }

    if (fetchedElement != null) {
      print('Found: $fetchedElement');
    } else {
      print('No match for status "$status"');
    }

    return fetchedElement;
  }

  String formattedDate(String utcString) {
    DateTime localDateTime = DateTime.parse(utcString).toLocal();
    // Format nicely
    return DateFormat('yyyy-MM-dd hh:mm a').format(localDateTime);
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _loading = true;
      });
      print('INIT STARTED');
      final updates = await supabaseHelper.getOrderupdates(widget.order.id);

      double discount = 0;
      String latest = 'Pending';
      if (widget.order.discount?['code'] != null) {
        if (widget.order.discount?['type'] == 'percentage') {
          final rate = (widget.order.discount?['value'] ?? 0).toDouble();
          discount = widget.order.totalPrice * (rate / 100);
        } else if (widget.order.discount?['type'] == 'fixed') {
          discount = (widget.order.discount?['value'] ?? 0).toDouble();
        }
      }

      if (updates.isNotEmpty) {
        latest = updates.last['status'];
      } else {
        latest = widget.order.status;
      }

      print(latest);

      setState(() {
        _discount = discount;
        _loading = false;
        _currentStatus = latest;
        _updates = updates;
      });

      print('Parsed updates: $updates');
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return LoadingScreens(
        message: 'Loading...',
        error: false,
        onRetry: null,
      );
    }
    return Scaffold(
      backgroundColor: const Color(0XFFFFFAED),
      appBar: AppBar(
        backgroundColor: const Color(0xFF38241D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Customer Information Card
            _buildCustomerInfoCard(),
            const SizedBox(height: 16),

            // Order Items Card
            _buildOrderItemsCard(),
            const SizedBox(height: 16),

            // Order Timeline Card
            _buildOrderTimelineCard(),
            const SizedBox(height: 16),

            // Payment Details Card
            _buildPaymentDetailsCard(),
            const SizedBox(height: 100), // Extra space for floating button
          ],
        ),
      ),
      floatingActionButton: OrderStatusFabOptimized(
        currentStatus: _currentStatus,
        loading: _loading,
        orderID: widget.order.id,
        deliveryMethod: _deliveryMethod,
        onStatusChanged: () => _loadInitialData(),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF603B17),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with dropdown
          GestureDetector(
            onTap: () {
              setState(() {
                _isCustomerInfoExpanded = !_isCustomerInfoExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: _isCustomerInfoExpanded
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFE7D3B4), width: 1),
                      )
                    : null,
                borderRadius: _isCustomerInfoExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      color: Color(0xFF38241D),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isCustomerInfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8E4B0E),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isCustomerInfoExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Customer Name
                  Text(
                    widget.order.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      color: Color(0xFF38241D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.order.email,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Quicksand',
                      color: Color(0xFF8E4B0E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/qricon.svg',
                          width: 16,
                          height: 16,
                          color: const Color(0xFF1976D2),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Online Payment',
                          style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customer Details
                  _buildInfoRow(
                      Icons.email_outlined, 'Email', widget.order.email),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone_outlined, 'Number',
                      widget.order.phone_number),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on_outlined, 'Address',
                      widget.order.address),
                  const SizedBox(height: 12),
                  _buildMethodRow(),
                  const SizedBox(height: 12),

                  // Vouchers
                  if (widget.order.discount?['code'] != null)
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined,
                            color: Color(0xFF8E4B0E), size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Discount:',
                          style: TextStyle(
                            color: Color(0xFF8E4B0E),
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0XFFFFFAED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.order.discount?['code'],
                            style: TextStyle(
                              color: Color(0xFF7B5B3C),
                              fontFamily: 'Quicksand',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF8E4B0E), size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E4B0E),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF38241D),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.local_shipping_outlined,
            color: Color(0xFF8E4B0E), size: 20),
        const SizedBox(width: 12),
        const SizedBox(
          width: 80,
          child: Text(
            'Method',
            style: TextStyle(
              color: Color(0xFF8E4B0E),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE1BEE7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _deliveryMethod,
            style: const TextStyle(
              color: Color(0xFF7B1FA2),
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF603B17),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isOrderItemsExpanded = !_isOrderItemsExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: _isOrderItemsExpanded
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFE7D3B4), width: 1))
                    : null,
                borderRadius: _isOrderItemsExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    'Order#: ${widget.product.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      color: Color(0xFF603B17),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentStatus,
                      style: TextStyle(
                        color: _getStatusColor(_currentStatus),
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isOrderItemsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8E4B0E),
                  ),
                ],
              ),
            ),
          ),

          // Order Items
          if (_isOrderItemsExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.items.length,
              separatorBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Divider(
                  color: Color(0xFFE7D3B4),
                  height: 1,
                  thickness: 1,
                ),
              ),
              itemBuilder: (context, index) {
                final item = widget.order.items[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Item Details (Left side)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₱${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF603B17),
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.name} (${item.size})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF603B17),
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Coffee Image (Right side)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F2EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.img != null
                              ? Image.network(
                                  item.img ??
                                      'https://placehold.co/200x150/png',
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/coffee_order_pic.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Helper to determine if status is completed
  bool _isStatusCompleted(String timelineStatus) {
    if (_currentStatus.isEmpty) return false;

    String current = _currentStatus.toLowerCase().trim();
    String timeline = timelineStatus.toLowerCase().trim();

    // Rejected or Cancelled orders
    if (current == 'rejected' || current == 'cancelled') {
      return timeline == 'order placed';
    }

    // Normal flow
    List<String> statusOrder = [
      'order placed',
      'Pending',
      'processing',
      _deliveryMethod.toLowerCase().trim() == 'walk-in'
          ? 'ready to pickup'
          : 'for delivery',
      'completed'
    ];

    int currentIndex = -1;
    int timelineIndex = -1;

    for (int i = 0; i < statusOrder.length; i++) {
      if (statusOrder[i] == current) currentIndex = i;
      if (statusOrder[i] == timeline) timelineIndex = i;
    }

    // If current status not found in order, return false
    if (currentIndex == -1) return false;

    return timelineIndex <= currentIndex;
  }

  Widget _buildOrderTimelineCard() {
    bool isWalkIn = _deliveryMethod.toLowerCase() == 'walk-in';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF603B17),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isTimelineExpanded = !_isTimelineExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: _isTimelineExpanded
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFE7D3B4), width: 1),
                      )
                    : null,
                borderRadius: _isTimelineExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text(
                    'Order Timeline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      color: Color(0xFF603B17),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isTimelineExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8E4B0E),
                  ),
                ],
              ),
            ),
          ),
          if (_isTimelineExpanded) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Order Placed
                  _buildTimelineItem(
                    true,
                    // _isStatusCompleted('Order Placed')
                    // ?
                    const Color(0xFFE27D19),
                    // : Colors.grey,

                    Icons.shopping_cart_checkout,
                    'Order Placed',
                    'on ${formattedDate(widget.order.created_at)}',
                    isLast: false,
                  ),

                  // Pending
                  _buildTimelineItem(
                    true,
                    const Color(0xFFE27D19),
                    // _isStatusCompleted('Pending')
                    //     ? const Color(0xFFFF9800)
                    //     : Colors.grey,
                    Icons.pending_actions,
                    'Pending',
                    'Order is pending...',
                    isLast: false,
                  ),

                  if (hasStatus('Processing') != null)
                    // Processing
                    _buildTimelineItem(
                      true,
                      const Color(0xFF2196F3),
                      Icons.autorenew,
                      'Processing',
                      '${hasStatus('Processing')?['remarks']} - ${formattedDate(hasStatus('Processing')?['created_at'])}',
                      isLast: false,
                    ),

                  if (hasStatus('Ready to Pickup') != null)
                    // For Delivery / Ready to Pickup
                    _buildTimelineItem(
                      true,
                      const Color(0xFFFF9800),
                      Icons.store,
                      'Ready to Pickup',
                      '${hasStatus('Ready to Pickup')?['remarks']} - ${formattedDate(hasStatus('Ready to Pickup')?['created_at'])}',
                      isLast: false,
                    ),

                  if (hasStatus('Completed') != null)
                    // For Delivery / Ready to Pickup
                    _buildTimelineItem(
                      true,
                      const Color(0xFF4CAF50),
                      Icons.check_circle,
                      'Complete',
                      '${hasStatus('Completed')?['remarks']} - ${formattedDate(hasStatus('Completed')?['created_at'])}',
                      isLast: true,
                    ),

                  if (hasStatus('Rejected') != null)
                    // For Delivery / Ready to Pickup
                    _buildTimelineItem(
                      true,
                      const Color.fromARGB(255, 237, 60, 7),
                      Icons.error,
                      'Complete',
                      '${hasStatus('Rejected')?['remarks']} - ${formattedDate(hasStatus('Rejected')?['created_at'])}',
                      isLast: true,
                    ),

                  if (hasStatus('Cancelled') != null)
                    // For Delivery / Ready to Pickup
                    _buildTimelineItem(
                      true,
                      const Color.fromARGB(255, 237, 60, 7),
                      Icons.error,
                      'Cancelled',
                      '${hasStatus('Cancelled')?['remarks']} - ${formattedDate(hasStatus('Cancelled')?['created_at'])}',
                      isLast: true,
                    ),
                  // if (hasStatus('Completed') != null)
                  //   // Completed
                  //   _buildTimelineItem(
                  //     _isStatusCompleted('Completed'),
                  //     _isStatusCompleted('Completed')
                  //         : Colors.grey,
                  //     Icons.check_circle,
                  //     'Completed',
                  //     'Your order is completed on 16\nAug 2025, 10:35 PM',
                  //     isLast: true,
                  //   ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    bool isCompleted,
    Color color,
    IconData icon,
    String title,
    String subtitle, {
    required bool isLast,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: isCompleted ? color : Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? const Color(0xFF38241D) : Colors.grey,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCompleted ? const Color(0xFF8E4B0E) : Colors.grey,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF603B17),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isPaymentDetailsExpanded = !_isPaymentDetailsExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: _isPaymentDetailsExpanded
                    ? const Border(
                        bottom: BorderSide(color: Color(0xFFE7D3B4), width: 1),
                      )
                    : null,
                borderRadius: _isPaymentDetailsExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt, color: Color(0xFFE27D19), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      color: Color(0xFF603B17),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isPaymentDetailsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF8E4B0E),
                  ),
                ],
              ),
            ),
          ),
          if (_isPaymentDetailsExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // _buildPaymentRow('Shipping', '₱ 50.00'),
                  // const SizedBox(height: 12),
                  _buildPaymentRow('Subtotal', '₱ ${widget.order.totalPrice}'),
                  const SizedBox(height: 12),
                  if (widget.order.discount?['code'] != null)
                    _buildPaymentRow('Voucher Applied', '-₱ $_discount ',
                        isVoucher: true),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE7D3B4)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Total Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Quicksand',
                          color: Color(0xFF38241D),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₱ ${totalPayment.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Quicksand',
                          color: Color(0xFF38241D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount,
      {bool isVoucher = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Quicksand',
            color: Color(0xFF8E4B0E),
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Quicksand',
            color: isVoucher ? Colors.red : const Color(0xFF38241D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'processing':
        return const Color(0xFF2196F3);
      case 'for delivery':
        return const Color(0xFF9C27B0);
      case 'ready to pickup':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFF44336);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF8E4B0E);
    }
  }
}

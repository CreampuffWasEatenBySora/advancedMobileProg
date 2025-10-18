import 'package:flutter/material.dart';
import 'package:firebase_nexus/appColors.dart';
import 'package:intl/intl.dart';
import './discountEdit.dart';

// Reusable ListTile for previous orders
class PreviousOrderTile extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String usedAgo; // e.g. "1 hr ago"
  final double prevPrice;
  final double discountedPrice;

  const PreviousOrderTile({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.usedAgo,
    required this.prevPrice,
    required this.discountedPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // 👈 custom Y padding
      child: ListTile(
        leading: const Icon(Icons.room_service, color: AppColors.input),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$orderId",
              style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.secondary),
            ),
            Text(
              "Used $usedAgo",
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Customer name
            Text(
              customerName,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),

            // Price info
            Row(
              children: [
                // Previous price (strikethrough)
                Text(
                  "₱${prevPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 13,
                    color: AppColors.input,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
                // Discounted price
                Text(
                  "₱${discountedPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Map<String, Color> _getColors(String status) {
    switch (status) {
      case 'Active':
        return {
          'bg': const Color(0xFFCBF0D8),
          'text': const Color(0xFF1EA44B),
        };
      case 'Expired':
        return {
          'bg': const Color(0xFFFFE0E0),
          'text': const Color(0xFFD32F2F),
        };
      default:
        return {
          'bg': const Color(0xFFEDEDED),
          'text': const Color(0xFF333333),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w600,
          color: colors['text'],
          fontSize: 12,
        ),
      ),
    );
  }
}

class DiscountTypeBadge extends StatelessWidget {
  final String type;
  const DiscountTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF8F6F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E8E57)),
      ),
    );
  }
}

class DiscountViewPage extends StatelessWidget {
  final String discountCode;
  final String description;
  final String status;
  final String discountType;
  final DateTime createdAt;
  final int usedCount;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;

  DiscountViewPage({
    super.key,
    this.discountCode = "DISCOUNT2025",
    this.description = "Placeholder description for this discount.",
    this.status = "Active",
    this.discountType = "Fixed Amount",
    DateTime? createdAt,
    this.usedCount = 5,
    this.discountValue = 10.0,
    DateTime? startDate,
    DateTime? endDate,
  })  : createdAt = createdAt ?? DateTime(2025, 1, 1),
        startDate = startDate ?? DateTime(2025, 1, 1),
        endDate = endDate ?? DateTime(2025, 1, 31);

  @override
  Widget build(BuildContext context) {
    final List<String> previousOrders = [
      "Order #001",
      "Order #002",
      "Order #003",
    ];

    final formattedStartDate = DateFormat('MMM d, yyyy').format(startDate);
    final formattedEndDate = DateFormat('MMM d, yyyy').format(endDate);
    final formattedCreated = DateFormat('MMM d, yyyy').format(createdAt);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "View Discount",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.edit, color: Colors.white),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => DiscountEdit(
          //           code: "SAVE10",
          //           description: "10% off on all items",
          //           discountType: "percentage",
          //           discountValue: "10",
          //           usageLimit: "5",
          //           startDate: DateTime.now(),
          //           endDate: DateTime.now().add(const Duration(days: 30)),
          //           isAvailable: true,
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Discount details container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Created + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Created at $formattedCreated",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          color: AppColors
                              .input, // or Colors.grey, Colors.black54 etc.
                        ),
                      ),
                      StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Discount code
                  Text(
                    discountCode,
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                        color: AppColors.secondary),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DiscountTypeBadge(type: discountType),
                      Text(
                        "-\₱${discountValue.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: AppColors.input),
                  ),
                  const SizedBox(height: 12),

                  // Discount type + value
                  const SizedBox(height: 12),

                  // Dashed line
                  Container(
                    width: double.infinity,
                    height: 1,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE9BBA9),
                          style: BorderStyle.solid, // dashed not native
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Uses + date range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Uses",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: AppColors.input,
                            ),
                          ),
                          const SizedBox(
                              width: 6), // space between label and value
                          Text(
                            "$usedCount",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.input,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$formattedStartDate - $formattedEndDate",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Collapsible Previous Orders
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ExpansionTile(
                shape: const RoundedRectangleBorder(
                  side: BorderSide.none, // removes border when expanded
                ),
                collapsedShape: const RoundedRectangleBorder(
                  side: BorderSide.none, // removes border when collapsed
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Previous Orders",
                          style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary),
                        ),
                      ],
                    ),
                    Text(
                      "${previousOrders.length} orders",
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: AppColors.input,
                      ),
                    ),
                  ],
                ),
                children: previousOrders
                    .map((order) => PreviousOrderTile(
                          orderId: order, // placeholder from your list
                          customerName: "Juan Dela Cruz", // placeholder
                          usedAgo: "1 hr ago", // placeholder
                          prevPrice: 100.0, // placeholder
                          discountedPrice: 90.0, // placeholder
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

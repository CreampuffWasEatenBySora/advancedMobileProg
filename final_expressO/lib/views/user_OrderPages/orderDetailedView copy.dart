// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../models/product.dart';

// class UserOrderDetailedView extends StatelessWidget {
//   final Product product;
//   final String orderStatus;

//   const UserOrderDetailedView({
//     super.key,
//     required this.product,
//     required this.orderStatus,
//   });

//   // Helper method to determine current stage based on orderStatus
//   int _getCurrentStage(String status) {
//     switch (status.toLowerCase()) {
//       case 'Pending':
//         return 0;
//       case 'processing':
//         return 2;
//       case 'completed':
//         return 4;
//       case 'cancelled':
//       case 'rejected':
//         return 0; // Show at start for cancelled/rejected orders
//       default:
//         return 0;
//     }
//   }

//   // Helper method to get status color
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'Pending':
//         return Colors.orange;
//       case 'processing':
//         return Colors.blue;
//       case 'completed':
//         return Colors.green;
//       case 'cancelled':
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentStage = _getCurrentStage(orderStatus);

//     return Scaffold(
//       backgroundColor: const Color(0XFFFFFAED),
//       appBar: AppBar(
//         backgroundColor: const Color(0XFFFFFAED),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.chevron_left),
//           iconSize: 32,
//           color: const Color(0xFF2D1D17),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
//             child: Text(
//               'Track Order#:',
//               style: TextStyle(
//                 fontFamily: 'Quicksand',
//                 fontWeight: FontWeight.w700,
//                 fontSize: 22,
//                 color: Color(0xFF2D1D17),
//               ),
//             ),
//           ),

//           // Main container with all sections
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Container(
//               width: double.infinity,
//               height: MediaQuery.of(context).size.height * 0.75,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 border: Border.all(
//                   color: const Color(0xFF2D1D17),
//                   width: 1.5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Order ID section
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
//                     child: Text(
//                       'Order#: ${product.id ?? "N/A"}',
//                       style: const TextStyle(
//                         fontFamily: 'Quicksand',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 20,
//                         color: Color(0xFF2D1D17),
//                       ),
//                     ),
//                   ),
//                   // Divider
//                   const Divider(
//                     color: Color(0xFF2D1D17),
//                     thickness: 1.5,
//                     height: 0,
//                   ),
//                   // Order details + image
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Order info
//                         Expanded(
//                           flex: 3,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 product.name,
//                                 style: const TextStyle(
//                                   fontFamily: 'Quicksand',
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 18,
//                                   color: Color(0xFF2D1D17),
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 '₱${product.price.toStringAsFixed(2)}',
//                                 style: const TextStyle(
//                                   fontFamily: 'Quicksand',
//                                   fontWeight: FontWeight.w700,
//                                   fontSize: 20,
//                                   color: Color(0xFF2D1D17),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               Row(
//                                 children: [
//                                   const Text(
//                                     'Order Status: ',
//                                     style: TextStyle(
//                                       fontFamily: 'Quicksand',
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 16,
//                                       color: Color(0xFF2D1D17),
//                                     ),
//                                   ),
//                                   Text(
//                                     orderStatus,
//                                     style: TextStyle(
//                                       fontFamily: 'Quicksand',
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 16,
//                                       color: _getStatusColor(orderStatus),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Coffee image
//                         Padding(
//                           padding: const EdgeInsets.only(left: 12),
//                           child: Image.asset(
//                             'assets/images/coffee_img.png',
//                             height: 70,
//                             width: 70,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Divider
//                   const Divider(
//                     color: Color(0xFF2D1D17),
//                     thickness: 1.5,
//                     height: 0,
//                   ),
//                   // Track your order title
//                   const Padding(
//                     padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
//                     child: Text(
//                       'Track your order',
//                       style: TextStyle(
//                         fontFamily: 'Quicksand',
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18,
//                         color: Color(0xFF603B17),
//                       ),
//                     ),
//                   ),
//                   // Order tracker timeline
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
//                       child: _OrderTimeline(
//                         currentStage: currentStage,
//                         stages: const [
//                           {
//                             'title': 'Order Placed',
//                             'subtitle':
//                                 'We have received your order on 16-Aug-2025'
//                           },
//                           {
//                             'title': 'Order Confirmed',
//                             'subtitle': 'We has been confirmed\n16-Aug-2025'
//                           },
//                           {
//                             'title': 'Order Processed',
//                             'subtitle': 'We are now preparing your order.'
//                           },
//                           {
//                             'title': 'Ready to Serve',
//                             'subtitle': 'Your Order is ready to serve.'
//                           },
//                           {
//                             'title': 'Order Completed',
//                             'subtitle':
//                                 'Your Order is completed on 16-Aug-2025, 15:03 PM'
//                           },
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Cancel Order button area (only show if not already cancelled/rejected/completed)
//           if (!['cancelled', 'rejected', 'completed']
//               .contains(orderStatus.toLowerCase()))
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 16),
//                       minimumSize: const Size(160, 52),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       textStyle: const TextStyle(
//                           fontFamily: 'Quicksand',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700),
//                     ),
//                     onPressed: () async {
//                       final confirmed = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           titlePadding: EdgeInsets.zero,
//                           title: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 40,
//                                   height: 40,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFFE27D19),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(Icons.report_problem,
//                                       color: Colors.white, size: 20),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 const Expanded(
//                                   child: Text(
//                                     'Cancel Order',
//                                     style: TextStyle(
//                                       fontFamily: 'Quicksand',
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           content: const Padding(
//                             padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
//                             child: Text(
//                               'Are you sure you want to cancel this order? This action cannot be undone.',
//                               style: TextStyle(
//                                   fontFamily: 'Quicksand', fontSize: 14),
//                             ),
//                           ),
//                           actionsPadding:
//                               const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                           actionsAlignment: MainAxisAlignment.end,
//                           actions: [
//                             OutlinedButton(
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: const Color(0xFF2D1D17),
//                                 side:
//                                     const BorderSide(color: Color(0xFFBDB6AE)),
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 18, vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8)),
//                                 textStyle: const TextStyle(
//                                     fontFamily: 'Quicksand',
//                                     fontWeight: FontWeight.w600),
//                               ),
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: const Text('No'),
//                             ),
//                             const SizedBox(width: 8),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 18, vertical: 12),
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8)),
//                                 textStyle: const TextStyle(
//                                     fontFamily: 'Quicksand',
//                                     fontWeight: FontWeight.w700),
//                               ),
//                               onPressed: () => Navigator.of(context).pop(true),
//                               child: const Text('Yes, cancel'),
//                             ),
//                           ],
//                         ),
//                       );

//                       if (confirmed == true && context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Order cancelled')),
//                         );
//                         // TODO: call backend / update DB to cancel the order
//                         Navigator.of(context).pop();
//                       }
//                     },
//                     child: const Text('Cancel Order'),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _OrderTimeline extends StatelessWidget {
//   final int currentStage;
//   final List<Map<String, String>> stages;

//   const _OrderTimeline({
//     required this.currentStage,
//     required this.stages,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: stages.length,
//       itemBuilder: (context, index) {
//         final isActive = index <= currentStage;
//         final stage = stages[index];

//         return IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Left margin
//               const SizedBox(width: 8),

//               // Small dot and vertical line column
//               Column(
//                 children: [
//                   const SizedBox(height: 14),
//                   // Small dot on the line
//                   Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: isActive
//                           ? const Color(0xFFE27D19)
//                           : const Color(0xFFDCD6D0),
//                       shape: BoxShape.circle,
//                     ),
//                   ),

//                   // Vertical connector
//                   if (index != stages.length - 1)
//                     Expanded(
//                       child: Container(
//                         width: 2,
//                         margin: const EdgeInsets.only(top: 8),
//                         color: (isActive && index < currentStage)
//                             ? const Color(0xFFE27D19)
//                             : const Color(0xFFDCD6D0),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(width: 12),

//               // Large circular icon column (to the right of the line)
//               Column(
//                 children: [
//                   const SizedBox(height: 6),
//                   Container(
//                     width: 64,
//                     height: 64,
//                     decoration: BoxDecoration(
//                       color: isActive
//                           ? const Color(0xFFE27D19)
//                           : const Color(0xFFDCD6D0),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: _svgForIndex(index),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(width: 16),

//               // Content column with extra spacing before title
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 24, top: 6),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       Text(
//                         stage['title']!,
//                         style: const TextStyle(
//                           fontFamily: 'Quicksand',
//                           fontWeight: FontWeight.w700,
//                           fontSize: 18,
//                           color: Color(0xFF2D1D17),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         stage['subtitle']!,
//                         style: TextStyle(
//                           fontFamily: 'Quicksand',
//                           fontSize: 14,
//                           color: const Color(0xFF2D1D17).withOpacity(0.8),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Return an SvgPicture for each stage using assets in assets/images/
//   Widget _svgForIndex(int i) {
//     switch (i) {
//       case 0:
//         return SvgPicture.asset('assets/images/orderplacedicon.svg',
//             width: 28, height: 28);
//       case 1:
//         return SvgPicture.asset('assets/images/orderconfirmed.svg',
//             width: 36, height: 36);
//       case 2:
//         return SvgPicture.asset('assets/images/orderprocessed.svg',
//             width: 32, height: 32);
//       case 3:
//         return SvgPicture.asset('assets/images/readytoserve.svg',
//             width: 32, height: 32);
//       case 4:
//         // Use a white check mark icon for completed
//         return const Icon(Icons.check, color: Colors.white, size: 28);
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }

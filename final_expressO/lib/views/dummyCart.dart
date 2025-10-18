// import 'package:firebase_nexus/appColors.dart';
// import 'package:firebase_nexus/providers/navigation_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/product.dart';
// import '../helpers/local_database_helper.dart';
// import 'user_OrderPages/orderDetailedView.dart';

// class SQLitePage extends StatefulWidget {
//   const SQLitePage({super.key});

//   @override
//   State<SQLitePage> createState() => _SQLitePageState();
// }

// class _SQLitePageState extends State<SQLitePage> {
//   @override
//   Widget build(BuildContext context) {
//     final navProvider = Provider.of<NavigationProvider>(context);
//     // int dummyId = 0;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.secondary,
//         title: const Text(
//           "Your Cart",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.normal,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<List<Product>>(
//         future: SQLFliteDatabaseHelper().getCart(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No items in cart"));
//           }

//           final products = snapshot.data!;

//           return ListView.builder(
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: AppColors.secondary.withOpacity(0.2),
//                   child: Text(product.name[0].toUpperCase()),
//                 ),
//                 title: Text(product.name),
//                 subtitle: Text(
//                   "₱${product.price.toStringAsFixed(2)}\nProvider value: ${navProvider.selectedIndex}",
//                 ),
//                 isThreeLine: true,
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.receipt_long, color: Colors.blue),
//                       tooltip: 'Order',
//                       onPressed: () {
//                         // Navigate to detailed order view for this product
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => UserOrderDetailedView(
//                               product: product,
//                               orderStatus: 'Processed',
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () async {
//                         // print(product.id);
//                         await SQLFliteDatabaseHelper()
//                             .deleteProduct(product.id);
//                         // Refresh UI
//                         setState(
//                             () {}); // 🔥 triggers FutureBuilder to run again
//                       },
//                     ),
//                   ],
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => UserOrderDetailedView(
//                         product: product,
//                         orderStatus: 'Processed',
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.secondary,
//         onPressed: () async {
//           // Insert a dummy product to test
//           // dummyId += 1;
//           // print(dummyId);
//           final dummy = Product(
//             // id: dummyId,
//             name: "Item ${DateTime.now().millisecondsSinceEpoch}",
//             price: 199.99,
//             quantity: 1,
//           );
//           await SQLFliteDatabaseHelper().insertProduct(dummy);
//           // Refresh UI
//           setState(() {});
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

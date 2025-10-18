import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_nexus/helpers/local_database_helper.dart';
import 'package:firebase_nexus/models/supabaseProduct.dart';
import '../checkout_user.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isEditing = true;
  List<SupabaseProduct> selectedItems = [];
  SQLFliteDatabaseHelper localDBhelper = SQLFliteDatabaseHelper();
  List<SupabaseProduct> cartList = [];

  @override
  void initState() {
    super.initState();
    _getCart();
  }

  Future<void> _getCart() async {
    final cart = await localDBhelper.getCart();
    print(cart.where((item) => item.included!).toList());
    setState(() {
      cartList = cart;
      selectedItems = cart.where((item) => item.included!).toList();
    });
  }

  Future<void> _updateQuantity(int id, bool increment) async {
    await localDBhelper.updateCartQuantity('Cart', id, increment);
    await _getCart(); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = selectedItems.fold<int>(0, (sum, e) => sum + e.quantity);
    final totalPrice =
        selectedItems.fold<double>(0, (sum, e) => sum + (e.price * e.quantity));

    return Scaffold(
      backgroundColor: const Color(0XFFFFFAED),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2c1d16),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       setState(() {
        //         isEditing = !isEditing;
        //         if (!isEditing) {
        //           selectedItems = List.generate(cartList.length, (_) => false);
        //         }
        //       });
        //     },
        //     child: Text(
        //       isEditing ? 'Done' : 'Edit',
        //       style: const TextStyle(
        //         fontFamily: 'Quicksand',
        //         color: Colors.white,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: cartList.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartList.length,
                    itemBuilder: (context, index) {
                      final item = cartList[index];

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isEditing)
                            SizedBox(
                              height: 120,
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: item.included!,
                                    onChanged: (value) {
                                      setState(() async {
                                        await localDBhelper.includeCheckout(
                                            item.id!, !item.included!);
                                        await _getCart(); // refresh UI
                                      });
                                    },
                                    activeColor: const Color(0xFFE27D19),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Color(0xFFE27D19)),
                                    onPressed: () async {
                                      await localDBhelper.deleteRow(
                                          'cart', item.id!);
                                      await _getCart();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Card(
                              color: const Color(0xFFFCFAF3),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Product image
                                    Image.network(
                                      item.img as String,
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 12),

                                    // Product details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${item.category} — ${item.variation}',
                                            style: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '₱${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF603B17),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Quantity controls
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: Color(0xFF603B17)),
                                          onPressed: () =>
                                              _updateQuantity(item.id!, true),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: item.quantity <= 1
                                                ? Colors.grey
                                                : const Color(0xFF603B17),
                                          ),
                                          onPressed: item.quantity <= 1
                                              ? null
                                              : () => _updateQuantity(
                                                  item.id!, false),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom summary bar
                Container(
                  height: 70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Items: $totalItems',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Total Price: ₱${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF603B17),
                            ),
                          ),
                        ],
                      ),

                      // Checkout
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE27D19),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: cartList.isNotEmpty
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CheckoutPage(
                                            checkOutItems: selectedItems,
                                          )),
                                )
                            : null,
                        child: const Text(
                          'Check Out',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

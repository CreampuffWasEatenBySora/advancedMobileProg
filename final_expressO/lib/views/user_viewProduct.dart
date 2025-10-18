import 'dart:io';

import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/helpers/local_database_helper.dart';
import 'package:firebase_nexus/models/supabaseProduct.dart';
import 'package:flutter/material.dart';

class UserViewProductPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const UserViewProductPage({Key? key, required this.productData})
      : super(key: key);

  @override
  State<UserViewProductPage> createState() => _UserViewProductPageState();
}

class _UserViewProductPageState extends State<UserViewProductPage> {
  Map<String, dynamic>? _selectedVariation;
  final _quantityController = TextEditingController();
  SQLFliteDatabaseHelper sqlFliteDatabaseHelper = SQLFliteDatabaseHelper();
  // late SupabaseProduct supaprod;
  late File? file;

  @override
  void initState() {
    super.initState();
    print('widget.productData');
    print(widget.productData);
    setState(() {
      _quantityController.text = '1';
    });
    // sqlFliteDatabaseHelper.resetDatabase();
    // _getFile();j
  }

  // void _getFile() async {
  //   try {
  //     File? fetched = await fileFromSupabase(widget.productData['img']);
  //     setState(() {
  //       file = fetched;
  //     });
  //   } catch (e) {
  //     print("Error $e");
  //   }
  // }

  void _storeToCart() async {
    final quant = int.tryParse(_quantityController.text) ?? 1;
    final name = widget.productData['name'];
    final variationName = _selectedVariation?["name"] ?? '';
    final product = SupabaseProduct(
      prodId: widget.productData['id'],
      name: name,
      included: true,
      category: widget.productData['category_name'],
      quantity: quant,
      variation: _selectedVariation!['name'],
      price: _selectedVariation!['price'],
      img: widget.productData['img'],
    );

    final result = await sqlFliteDatabaseHelper.insertCart('cart', product);
    final isSuccess = result['success'] == true;

    _showSnackBar(
      icon: isSuccess ? Icons.check : Icons.error,
      iconColor: isSuccess ? const Color(0xFFE27D19) : Colors.red,
      message: isSuccess
          ? '$quant $variationName $name${quant > 1 ? 's' : ''} added to cart!'
          : 'There was a problem on our end, please try again later!',
    );
  }

  void _showSnackBar({
    required IconData icon,
    required Color iconColor,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productData = widget.productData;
    final variations = (productData['variations'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6ED),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF4B2E19)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'View Product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B2E19),
                    ),
                  ),
                ],
              ),
            ),

            // Product Image
            Container(
              width: double.infinity,
              height: 280,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  productData['img'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.coffee,
                          size: 80, color: Color(0xFF4B2E19)),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Product Details
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price and Status Row

                      const SizedBox(height: 16),

                      // Product Name
                      Text(
                        productData['name'] as String,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2E19),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B2E19).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4B2E19).withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${productData['category_name'] ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4B2E19),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        productData['desc'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        height: 1,
                        color: const Color(0xFF4B2E19).withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),

                      const SizedBox(height: 24),

                      // Stock + Variations
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Variations as Chips
                          const Text(
                            'Size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2E19),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: variations.map((v) {
                              final isSelected =
                                  _selectedVariation?['name'] == v['name'];
                              return ChoiceChip(
                                label: Text(v['name']),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedVariation = selected
                                        ? v
                                        : null; // store full object
                                  });
                                },
                                selectedColor: const Color(0xFF4B2E19),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF4B2E19),
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor:
                                    const Color(0xFF4B2E19).withOpacity(0.05),
                              );
                            }).toList(),
                          ),
                          const Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2E19),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedVariation != null
                                    ? '₱${_selectedVariation!['price']}'
                                    : '₱${productData['lowest_price'] ?? '--'}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B2E19),
                                ),
                              ),
                              // ElevatedButton(
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: const Color(0xFFE27D19),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(12),
                              //     ),
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 20, vertical: 10),
                              //   ),
                              //   onPressed: () {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(
                              //         duration: const Duration(seconds: 2),
                              //         backgroundColor: Colors.white,
                              //         behavior: SnackBarBehavior.floating,
                              //         margin: const EdgeInsets.symmetric(
                              //             horizontal: 60, vertical: 400),
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(16),
                              //         ),
                              //         content: Column(
                              //           mainAxisSize: MainAxisSize.min,
                              //           children: [
                              //             const Icon(Icons.check,
                              //                 color: Color(0xFFE27D19),
                              //                 size: 28),
                              //             const SizedBox(height: 8),
                              //             Text(
                              //               'haha added to cart',
                              //               style: const TextStyle(
                              //                 color: Colors.black87,
                              //                 fontWeight: FontWeight.bold,
                              //                 fontSize: 16,
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     );
                              //   },
                              //   child: const Text(
                              //     'Add to Cart',
                              //     style: TextStyle(
                              //       color: Colors.white,
                              //       fontWeight: FontWeight.bold,
                              //       fontSize: 16,
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

// Quantity Input + Add to Cart Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity Input
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                labelStyle:
                                    const TextStyle(color: Color(0xFF4B2E19)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4B2E19)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixText: '/ ${productData['stock']}',
                              ),
                              onChanged: (val) {
                                final value = int.tryParse(val) ?? 0;
                                if (value > (productData['stock'] ?? 0)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Quantity exceeds available stock.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              controller: _quantityController,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Add to Cart Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE27D19),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _selectedVariation == null
                                ? null
                                : () async {
                                    final stock = productData['stock'] ?? 0;
                                    final inputText = _quantityController.text;
                                    final inputQuantity =
                                        int.tryParse(inputText) ?? 0;
                                    final name =
                                        productData['name'] ?? 'Product';

                                    print(inputQuantity);
                                    print(inputText);

                                    if (inputQuantity <= 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please enter a valid quantity.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    if (inputQuantity > stock) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Not enough stock available.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    // TODO: Insert your add-to-cart logic here
                                    // e.g. LocalDatabaseHelper.addToCart(productData, inputQuantity);
                                    _storeToCart();

                                    setState(() {
                                      _quantityController.text = '1';
                                    });
                                  },
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

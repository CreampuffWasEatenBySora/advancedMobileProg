import 'package:firebase_nexus/helpers/local_database_helper.dart';
import 'package:flutter/material.dart';

class ViewProductPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ViewProductPage({Key? key, required this.productData})
      : super(key: key);

  @override
  State<ViewProductPage> createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  Map<String, dynamic>? _selectedVariation;

  @override
  void initState() {
    print(widget.productData);
    super.initState();
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedVariation != null
                                ? '₱${_selectedVariation!['price']}'
                                : '₱${productData['lowest_price'] ?? '--'}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B2E19),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: getStatColor(
                                      productData['status'])['labelColor'] ??
                                  Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: getStatColor(
                                        productData['status'])['textColor'] ??
                                    Color(0xFF757575),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              productData['status'] as String,
                              style: TextStyle(
                                color: getStatColor(
                                        productData['status'])['textColor'] ??
                                    Color(0xFF757575),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

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
                          // Stock
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF4B2E19),
                                fontWeight: FontWeight.w600,
                              ),
                              children: [
                                const TextSpan(text: 'Stock  '),
                                TextSpan(
                                  text: productData['stock']?.toString() ?? '0',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Variations as Chips
                          const Text(
                            'Available Sizes',
                            style: TextStyle(
                              fontSize: 18,
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

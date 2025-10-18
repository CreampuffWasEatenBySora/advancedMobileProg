import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/helpers/userPageSupabaseHelper.dart';
import 'package:firebase_nexus/widgets/loading_screens.dart';
import 'package:flutter/material.dart';
import 'package:firebase_nexus/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'notifPage.dart';
import 'orderDetails.dart';
import '../widgets/user_addtocart_fab.dart';
import 'user_viewProduct.dart';
import 'user_OrderPages/CartList.dart';

class NeilCart extends StatefulWidget {
  const NeilCart({super.key});

  @override
  State<NeilCart> createState() => _NeilCartState();
}

class _NeilCartState extends State<NeilCart> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIconIndex = 0;
  final TextEditingController _categoryNameController = TextEditingController();
  final supabaseHelper = UserSupabaseHelper();

  bool _loading = true;
  final List<String> _categories = ['All'];
  List<Map<String, dynamic>> _products = [];
  final FocusNode _searchFocusNode = FocusNode();

  // ✅ Filtered list logic
  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> filtered = _products;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((product) =>
              (product['category_name'] ?? '').toString() == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product['name'].toString().toLowerCase();
        final desc = product['desc'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || desc.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        _performSearch();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      print('INIT STARTED');
      final categories = await supabaseHelper.getCategs();
      final products = await supabaseHelper.getProductsForUser(null);

      print('INIT FINISHED');
      print('categories fetched!');
      print(categories);
      print('products fetched!');
      print(products);

      setState(() {
        _loading = false;
        _categories.addAll(categories.map((e) => e['name'] as String).toList());
        _products = products;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _performSearch() async {
    setState(() => _loading = true);
    try {
      final products = await supabaseHelper.getProductsForUser(
        _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      print("Search error: $e");
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

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
          icon: const Icon(Icons.chevron_left, color: Color(0XFFFFFAED)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Color(0XFFFFFAED)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderDetails()),
              );
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.notifications_none, color: Color(0XFFFFFAED)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔽 Title + Search + Categories
          Container(
            width: double.infinity,
            color: const Color(0xFF38241D),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Enjoy your Favorite ',
                        style: TextStyle(color: Color(0XFFFFFAED)),
                      ),
                      TextSpan(
                        text: 'Coffee! ☕',
                        style: TextStyle(color: Color(0xFFE27D19)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔎 Search bar + filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF503228),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            color: Color(0xFF9E7A6E),
                          ),
                          decoration: const InputDecoration(
                            filled: false,
                            hintText: "Search coffee...",
                            hintStyle: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Color(0xFF9E7A6E),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                                Icon(Icons.search, color: Color(0xFF9E7A6E)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ☕ Categories
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 30),
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedIndex;
                      final text = _categories[index];
                      final textStyle = TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white.withOpacity(isSelected ? 1.0 : 0.5),
                      );

                      double underlineWidth = 0;
                      if (isSelected) {
                        final textPainter = TextPainter(
                          text: TextSpan(text: text, style: textStyle),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        )..layout();
                        underlineWidth = textPainter.size.width;
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            _selectedCategory = _categories[index];
                          });
                        },
                        child: SizedBox(
                          height: 30,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(text, style: textStyle),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 1),
                                  height: 4,
                                  width: underlineWidth,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE27D19),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // 📜 Grid of products
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.8, // approximate width:height ratio
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final variations = product['variations'] ?? 'Unknown';
                final name = product['name'] ?? 'Unknown';
                final price = product['lowest_price']?.toString() ?? 'N/A';
                final imageUrl =
                    product['img'] ?? 'https://placehold.co/200x150/png';

                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 180, // minimum height
                  ),
                  child: InkWell(
                    onTap: () {
                      // Temporary test data for product page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserViewProductPage(
                            productData: {
                              'id': product['id'],
                              'name': name,
                              'lowest_price': price,
                              'img': imageUrl,
                              'status': product['status'],
                              'desc': product['desc'],
                              'category_name': product['category_name'],
                              'stock': product['stock'],
                              'variations': variations,
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFAF3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: AspectRatio(
                              aspectRatio: 4 / 3, // maintain image ratio
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image),
                              ),
                            ),
                          ),

                          // Name
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Texts (name + price) on the left
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize:
                                          MainAxisSize.min, // wrap only content
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Color(0xFF2c1d16),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "₱$price",
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF603B17),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Add button on the right
                                  Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE27D19),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 16,
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => UserViewProductPage(
                                              productData: {
                                                'id': product['id'],
                                                'name': name,
                                                'lowest_price': price,
                                                'img': imageUrl,
                                                'status': product['status'],
                                                'desc': product['desc'],
                                                'category_name':
                                                    product['category_name'],
                                                'stock': product['stock'],
                                                'variations': variations,
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
      floatingActionButton: AddToCartFAB(
        itemCount: 3, // replace with your cart count
        onTap: () {
          // Show a temporary SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Going to Cart!'),
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to DummyOrderPage after a slight delay so SnackBar shows
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartPage(),
              ),
            );
          });
        },
      ),
    );
  }
}

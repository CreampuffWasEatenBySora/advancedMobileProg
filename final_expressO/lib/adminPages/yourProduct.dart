import 'package:firebase_nexus/adminPages/AddProduct.dart';
import 'package:firebase_nexus/adminPages/EditProductFlow.dart';
import 'package:firebase_nexus/adminPages/addProductFlow.dart';
import 'package:firebase_nexus/adminPages/editProduct.dart';
import 'package:firebase_nexus/adminPages/viewProduct.dart';
import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/helpers/local_database_helper.dart';
import 'package:firebase_nexus/widgets/confirm_modal.dart';
import 'package:firebase_nexus/widgets/loading_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:firebase_nexus/widgets/category_lateral.dart';

import './adminHome.dart';

class YourProductPage extends StatefulWidget {
  final String title;
  const YourProductPage({Key? key, required this.title}) : super(key: key);

  @override
  State<YourProductPage> createState() => _YourProductPageState();
}

class _YourProductPageState extends State<YourProductPage> {
  String _selectedCategory = 'All';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _selectedIconIndex = 0;
  final TextEditingController _categoryNameController = TextEditingController();

  final supabaseHelper = AdminSupabaseHelper();
  bool _loading = true;
  final List<String> _categories = ['All'];
  List<Map<String, dynamic>> _products = [];
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> filtered = _products;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product['category_name'] == _selectedCategory)
          .toList();
    }

    // Apply search filter
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
    print('STARTING INIT STATE');
    _loadInitialData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        // Trigger search when focus is lost
        // basically when the user stops typing and closes the keyboard
        _performSearch();
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      print('STARTED');

      final categories = await supabaseHelper.getAll("Categories", null, null);
      final products =
          await supabaseHelper.getAll("product_overview", null, null);
      if (categories.isNotEmpty) {
        print('Categoried loaded!');
        print(categories);
      }

      if (products.isNotEmpty) {
        print('products loaded!');
        print(products);
      }
      // _categories = categories;

      setState(() {
        _loading = false;
        _categories.addAll(categories.map((e) => e['name'] as String).toList());
        _products = products;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<UserProfile> fetchUserProfile() async {
    // TODO: replace with your real backend call
    await Future.delayed(const Duration(milliseconds: 300));
    return UserProfile(
      displayName: 'Express-O',
      email: 'admin123@gmail.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?...',
    );
  }

  Future<void> _performSearch() async {
    setState(() => _loading = true);

    try {
      final products = await supabaseHelper.getAll(
        "product_overview",
        _searchQuery.isNotEmpty ? _searchQuery : null,
        _searchQuery.isNotEmpty
            ? "name"
            : null, // 🔍 column to search (you can change this)
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
  Widget build(BuildContext context) {
    // 🔶 LOADING OVERLAY
    if (_loading) {
      return LoadingScreens(
        message: 'Loading...',
        error: false,
        onRetry: null,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFF38241D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 68, // slightly taller for breathing room
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              // onTap: () => _showCategoriesPanel(context),
              onTap: () => showCategoryLateral(context, handleSaveCategory),
              child: const Icon(
                Icons.sort_by_alpha,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],

        // Search bar + category chips below AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            color: const Color(0xFF38241D),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              children: [
                // 🔍 Search bar + filter
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF503228),
                            hintText: 'Search here...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // 🏷️ Category list
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Column(
                            children: [
                              Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFFE27D19)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  height: 3,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE27D19),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: AdminDrawer(
        profileFuture: fetchUserProfile(), // <-- your future method

        selectedRoute: "/products", // mark this as active/highlighted
        onNavigate: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search or category',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to ViewProductPage when the card is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewProductPage(productData: product),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product['img'] ?? '',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Price - not bold, normal weight
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Php ${product['lowest_price'].toString()}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xFF4B2E19),
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 8, top: 4, bottom: 4),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: getStatColor(
                                                      product['status'])[
                                                  'labelColor'],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              product['status'] as String,
                                              style: TextStyle(
                                                color: getStatColor(
                                                        product['status'])[
                                                    'textColor'],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Product name and status on the same line
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            product['name'] as String,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4B2E19),
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          PopupMenuButton<String>(
                                            color: Colors.white,
                                            icon: const Icon(
                                              Icons.more_vert,
                                              color: Color(0xFF4B2E19),
                                              size: 24,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            offset: const Offset(-10, 40),
                                            itemBuilder:
                                                (BuildContext context) => [
                                              PopupMenuItem<String>(
                                                value: 'edit',
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.edit_outlined,
                                                      color: Color(0xFF4B2E19),
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.redAccent,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.redAccent),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (String value) {
                                              if (value == 'edit') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Editproductflow(
                                                            productID:
                                                                product['id']),
                                                  ),
                                                );
                                              } else if (value == 'delete') {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      ConfirmationModal(
                                                    type: ConfirmationModalType
                                                        .delete,
                                                    onConfirm: () {
                                                      // Your delete logic here
                                                      print('Item deleted!');
                                                    },
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      // Description
                                      SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          product['desc'] as String,
                                          style: const TextStyle(
                                            color: Color(0xFF757575),
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE27D19),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
        onPressed: () {
          // Navigate to the AddProduct screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductFlow()),
          );
        },
      ),
    );
  }
}

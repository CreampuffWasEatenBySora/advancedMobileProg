import 'package:firebase_nexus/helpers/userPageSupabaseHelper.dart';
import 'package:firebase_nexus/models/order.dart';
import 'package:firebase_nexus/widgets/loading_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/product.dart';
import 'orderDetailedView.dart';

import '../notifPage.dart';
import 'CartList.dart';

class OrderListPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const OrderListPage({
    super.key,
    this.user,
  });

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderItem {
  final Product product;
  final String
      status; // 'All','Pending','Processing','Completed','Cancelled','pastry'

  _OrderItem({required this.product, required this.status});
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Order> _orders;
  String _search = '';
  bool _loading = true;
  final supabaseHelper = UserSupabaseHelper();

  // Filter variables
  List<String> _selectedStatuses = [];
  DateTimeRange? _selectedDateRange;
  double _minPrice = 0;
  double _maxPrice = 10000;

  // Add Category variables
  int _selectedIconIndex = 0;
  final TextEditingController _categoryNameController = TextEditingController();

  final tabs = [
    'All',
    'Pending',
    'Processing',
    'Completed',
    'Cancelled',
    'Rejected',
  ];

  // create mock orders with statuses
  List<_OrderItem> get _mockOrders {
    final statuses = [
      'Pending',
      'Processing',
      'Completed',
      'Cancelled',
      'Rejected',
    ];
    return List.generate(6, (i) {
      final p = Product(
          id: i + 100,
          name: 'Order ${999000 + i}',
          price: 110.0 + i * 10,
          quantity: 1 + (i % 3));
      return _OrderItem(product: p, status: statuses[i % statuses.length]);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      print('INIT STARTED');
      final rawOrders =
          await supabaseHelper.getOrdersForUser(widget.user?['id']);
      print('Orders fetched: $rawOrders');

      final orders = (rawOrders as List)
          .map((o) => Order.fromJson(Map<String, dynamic>.from(o)))
          .toList();

      setState(() {
        _loading = false;
        _orders = orders;
      });

      print('Parsed orders: $_orders');
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _loading = false);
    }
  }

  List<Order> _filteredForTab(int tabIndex) {
    final tab = tabs[tabIndex];
    var items = _orders.where((o) {
      final matchSearch = _search.isEmpty ||
          o.items.any(
              (i) => i.name.toLowerCase().contains(_search.toLowerCase())) ||
          o.id.toString().contains(_search);

      final matchStatus =
          _selectedStatuses.isEmpty || _selectedStatuses.contains(o.status);
      final matchPrice = o.totalPrice >= _minPrice && o.totalPrice <= _maxPrice;

      return matchSearch && matchStatus && matchPrice;
    }).toList();

    if (tab != 'All') {
      items = items
          .where((o) => o.status.toLowerCase() == tab.toLowerCase())
          .toList();
    }
    return items;
  }

//   Order getOrder(int index){
//     return  items[index];
//   }

//   final order =;
// final firstItem = order.items.isNotEmpty ? order.items.first : null;

  @override
  Widget build(BuildContext context) {
    // Apply Quicksand font family across this page
    final themeWithQuicksand = Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Quicksand'),
    );

    if (_loading) {
      return LoadingScreens(
        message: 'Loading...',
        error: false,
        onRetry: null,
      );
    }

    return Theme(
      data: themeWithQuicksand,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF38241D),
          elevation: 0,
          toolbarHeight: 60,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0XFFFFFAED)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined,
                  color: Color(0XFFFFFAED)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: Color(0XFFFFFAED)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotifPage()),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF503228),
                              hintText: 'Search here...',
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white70),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (v) => setState(() => _search = v),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _showFilterDialog,
                        borderRadius: BorderRadius.circular(5),
                        child: SvgPicture.asset(
                          'assets/images/filter_icon.svg',
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 30,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 0),
                    child: TabBar(
                      isScrollable: true,
                      controller: _tabController,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF9C7E60),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Quicksand',
                      ),
                      tabs: tabs.map((t) => Tab(text: t)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(tabs.length, (tabIndex) {
            final items = _filteredForTab(tabIndex);
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try a different search or filter',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => UserOrderDetailedPage(
                          order: item,
                          product: item.items.first,
                          orderStatus: item.status))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F2EC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: item.items.first != null
                              ? Image.network(
                                  item.items.first.image() ??
                                      'https://placehold.co/200x150/png',
                                  fit: BoxFit.cover)
                              : const Icon(Icons.inventory),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('Order #${items[index].id}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            fontFamily: 'Quicksand')),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                        color:
                                            items[index].status == 'Cancelled'
                                                ? const Color(0xFFF8D1D1)
                                                : const Color(0xFFF4E6DC),
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: Text(items[index].status,
                                        style: const TextStyle(
                                            color: Color(0xFF8E4B0E),
                                            fontFamily: 'Quicksand')),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₱${items[index].discounted.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Color(0xFF8E4B0E),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Quicksand'),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.items.first.size} ${item.items.first.name}, x${item.items.first.quantity}',
                                style: const TextStyle(
                                    color: Color(0xFFB99F92),
                                    fontFamily: 'Quicksand'),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Orders',
                  style: TextStyle(
                      fontFamily: 'Quicksand', fontWeight: FontWeight.w600)),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Filter
                    const Text('Order Status:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Quicksand')),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Pending',
                        'Processing',
                        'Completed',
                        'Cancelled',
                        'Rejected',
                      ].map((status) {
                        return FilterChip(
                          label: Text(status,
                              style: const TextStyle(
                                  fontSize: 12, fontFamily: 'Quicksand')),
                          selected: _selectedStatuses.contains(status),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                _selectedStatuses.add(status);
                              } else {
                                _selectedStatuses.remove(status);
                              }
                            });
                          },
                          selectedColor:
                              const Color(0xFFE27D19).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF8E4B0E),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Price Range Filter
                    const Text('Price Range:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Quicksand')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _minPrice.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Min Price',
                              prefixText: '₱',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final price = double.tryParse(value);
                              if (price != null) {
                                setDialogState(() => _minPrice = price);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: _maxPrice.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Max Price',
                              prefixText: '₱',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final price = double.tryParse(value);
                              if (price != null) {
                                setDialogState(() => _maxPrice = price);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Range Filter
                    const Text('Date Range:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Quicksand')),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTimeRange? range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                          initialDateRange: _selectedDateRange,
                        );
                        if (range != null) {
                          setDialogState(() => _selectedDateRange = range);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE7D3B4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range,
                                color: Color(0xFF8E4B0E)),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDateRange == null
                                  ? 'Select Date Range'
                                  : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                              style: const TextStyle(fontFamily: 'Quicksand'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedStatuses.clear();
                      _selectedDateRange = null;
                      _minPrice = 0;
                      _maxPrice = 10000;
                    });
                  },
                  child: const Text('Clear All',
                      style: TextStyle(
                          color: Colors.grey, fontFamily: 'Quicksand')),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(
                          color: Colors.grey, fontFamily: 'Quicksand')),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {}); // Refresh the main page with new filters
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE27D19),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply',
                      style: TextStyle(fontFamily: 'Quicksand')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

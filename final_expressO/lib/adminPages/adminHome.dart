import 'package:firebase_nexus/Profile/ShowProfile.dart';
import 'package:firebase_nexus/appColors.dart';
import 'package:firebase_nexus/helpers/AnalyticsSupabaseHelper.dart';
import 'package:firebase_nexus/main.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'adminTransactionHistory.dart';
import 'yourProduct.dart';
import 'discountPages/discountList.dart';
import 'orderPages/orderList.dart';
import 'package:provider/provider.dart';
import '../providers/userProvider.dart';
import 'profileAdmin.dart';
import 'analyticsVIew.dart';
import 'adminNotifPage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_nexus/widgets/category_lateral.dart';

// Entry point bootstrapping the admin dashboard module.
void main() {
  runApp(const AdminHome());
}

// Top-level widget hosting the routed admin experience.
void handleSaveCategory(Category category) {
  // Example: print the info
  print('Saved category: ${category.name}, iconIndex: ${category.iconIndex}');

  // TODO: Save to your database here
}

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFAF6EE),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (c) => const DashboardPage(),
        '/products': (c) => const YourProductPage(title: 'Products'),
        '/orders': (c) => const OrderListPage(),
        '/discounts': (c) => const DiscountListPage(),
        '/analytics': (c) => const AnalyticsVIew(),
        '/transactions': (c) => const adminTransactionHistory(),
        '/profile': (c) => const ShowProfile(),
        '/adminNotifPage': (context) => const AdminNotifPage(),
      },
      initialRoute: '/',
    );
  }
}

// Simulated profile/logout endpoints for the drawer header.
class BackendService {
  static Future<UserProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserProfile(
      displayName: 'Express-O',
      email: 'admin123@gmail.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?fit=crop&w=200&q=60',
    );
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}

// Simple immutable profile container used by the drawer.
class UserProfile {
  final String displayName;
  final String email;
  final String? avatarUrl;

  UserProfile({required this.displayName, required this.email, this.avatarUrl});
}

// Stateful screen that loads analytics + pending orders from Supabase.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdminSupabaseHelper _helper = AdminSupabaseHelper();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  late Future<_DashboardSnapshot> _dashboardFuture;
  late Future<UserProfile> _profileFuture;
  String _currentRoute = '/';

  @override
  void initState() {
    // Prepare profile + analytics fetches.
    super.initState();
    _loadData();
    _profileFuture = BackendService.getProfile();
  }

  // Triggers a fresh Supabase pull for analytics and pending orders.
  void _loadData() {
    _dashboardFuture = _fetchDashboard();
  }

  // Aggregates analytics snapshot plus filtered “Pending” orders.
  Future<_DashboardSnapshot> _fetchDashboard() async {
    final analytics = await _helper.fetchAnalyticsReport();
    final pending = await _helper.fetchPendingOrdersForApproval();
    return _DashboardSnapshot(analytics: analytics, pending: pending);
  }

  // Drawer navigation helper (handles logout as a special route).
  void _onNavigate(String route) {
    // close drawer then navigate
    Navigator.of(context).pop();
    if (route == '/logout') {
      _performLogout();
      return;
    }
    if (route != _currentRoute) {
      setState(() => _currentRoute = route);
      Navigator.of(context).pushNamed(route);
    }
  }

  // Simulated logout call followed by UI feedback.
  Future<void> _performLogout() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Clear user data (shared prefs + provider)
      await userProvider.clearUser(context);

      // Navigate to actual login route
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/tioLogin', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Shell containing drawer + analytics body.
    const safePadding = 16.0;
    return Scaffold(
      // attach a Drawer
      drawer: AdminDrawer(
        profileFuture: _profileFuture,
        selectedRoute: _currentRoute,
        onNavigate: _onNavigate,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: safePadding),
          child: FutureBuilder<_DashboardSnapshot>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final analytics = snapshot.data!.analytics;
              final pendingOrders = snapshot.data!.pending;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildTopBar(),
                    const SizedBox(height: 12),
                    _buildDonutCard(analytics),
                    const SizedBox(height: 16),
                    _buildShortcutsRow(),
                    const SizedBox(height: 18),
                    _buildStatisticsOverview(analytics),
                    const SizedBox(height: 18),
                    _buildPendingOrders(pendingOrders),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Header row with menu button, greeting, and avatar.
  Widget _buildTopBar() {
    return Row(
      children: [
        Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        const SizedBox(width: 6),
        const Text(
          'Hello, Admin',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {
            Navigator.pushNamed(context, '/adminNotifPage');
          },
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFF08F2A),
          child: Text(
            'AD',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Renders category-based donut chart using analytics totals.
  Widget _buildDonutCard(AdminAnalyticsReport analytics) {
    final stats = analytics.categoryStats;
    final palette = [
      const Color(0xFFE27D19),
      const Color(0xFFFFAF5F),
      const Color(0xFFB35900),
      const Color(0xFFE7B188),
      const Color(0xFF8E5A2C),
      const Color(0xFF6F3A12),
    ];

    final sections = stats.isEmpty
        ? [
            PieChartSectionData(
              value: 1,
              radius: 46,
              showTitle: false,
              color: Colors.grey.shade300,
            )
          ]
        : List.generate(stats.length, (index) {
            final stat = stats[index];
            return PieChartSectionData(
              value: stat.itemCount.toDouble(),
              radius: 46,
              showTitle: false,
              color: palette[index % palette.length],
            );
          });

    final legendEntries = stats.isEmpty
        ? <_LegendEntry>[_LegendEntry('No data', Colors.grey.shade300)]
        : List.generate(stats.length, (index) {
            final stat = stats[index];
            final label = stat.categoryName?.isNotEmpty == true
                ? stat.categoryName!
                : 'Category ${stat.categoryId}';
            return _LegendEntry(
              '$label (${stat.itemCount})',
              palette[index % palette.length],
            );
          });

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            SizedBox(
              height: 190,
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                        child:
                            _buildDonutChart(analytics.totalOrders, sections)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: legendEntries
                  .map((entry) => _buildLegendItem(entry))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  // Legend chip helper for donut categories.
  Widget _buildLegendItem(_LegendEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: entry.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(entry.label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // Pie chart widget showing total completed orders in the center.
  Widget _buildDonutChart(int totalOrders, List<PieChartSectionData> sections) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 46,
            sections: sections,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$totalOrders',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D3510))),
            const SizedBox(height: 4),
            const Text('Total Orders',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        )
      ],
    );
  }

  // Shortcut cards that deep-link to other admin modules.
  Widget _buildShortcutsRow() {
    final items = [
      _ShortcutItem(
        icon: Icons.coffee_outlined,
        label: 'Products',
        route: '/products', // This will navigate to YourProductPage
      ),
      _ShortcutItem(
          icon: Icons.receipt_long, label: 'Orders', route: '/orders'),
      _ShortcutItem(
          icon: Icons.local_offer_outlined,
          label: 'Discounts',
          route: '/discounts'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shortcuts', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((i) => _buildShortcutCard(i)).toList(),
        ),
      ],
    );
  }

  // Individual shortcut tile renderer.
  Widget _buildShortcutCard(_ShortcutItem item) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(item.route),
          child: Container(
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 28, color: const Color(0xFFF08F2A)),
                const SizedBox(height: 8),
                Text(item.label, style: const TextStyle(fontSize: 13))
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Two-card summary: total sales and total customers from Supabase.
  Widget _buildStatisticsOverview(AdminAnalyticsReport analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Statistics Overview',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                    color: const Color(0xFFF08F2A),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.attach_money, color: Colors.white),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Sales',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            _currencyFormat.format(analytics.totalSales),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.people_outline,
                          color: Color(0xFF8E4B0E)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Customers',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            '${analytics.totalCustomers}',
                            style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Pending orders list filtered to “Pending” statuses.
  Widget _buildPendingOrders(List<AdminPendingOrderSummary> pendingOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Pending Orders',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('· ${pendingOrders.length}',
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 8),
        if (pendingOrders.isEmpty)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              title: Text('No orders awaiting approval'),
              subtitle: Text('You are all caught up.'),
            ),
          )
        else
          Column(
            children: pendingOrders
                .map((ord) => _buildPendingOrderCard(ord))
                .toList(),
          ),
      ],
    );
  }

  // Single pending-order card with amount and timestamp.
  Widget _buildPendingOrderCard(AdminPendingOrderSummary ord) {
    final formattedDate =
        DateFormat('MMM d, yyyy • h:mm a').format(ord.createdAt.toLocal());
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        title: Row(
          children: [
            Expanded(
                child: Text(ord.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Text(_currencyFormat.format(ord.total),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF5D3510))),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${ord.orderId} • ${ord.itemsSummary}',
                style: const TextStyle(color: Colors.black45)),
            Text(formattedDate,
                style: const TextStyle(color: Colors.black38, fontSize: 12)),
          ],
        ),
        onTap: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Open order ${ord.orderId}'))),
      ),
    );
  }
}

// Lightweight struct for shortcut metadata.
class _ShortcutItem {
  final IconData icon;
  final String label;
  final String route; // Add this line
  _ShortcutItem({required this.icon, required this.label, required this.route});
}

// Drawer widget wrapping navigation items and profile header.
class AdminDrawer extends StatelessWidget {
  final Future<UserProfile> profileFuture;
  final String selectedRoute;
  final void Function(String route) onNavigate;

  const AdminDrawer({
    super.key,
    required this.profileFuture,
    required this.selectedRoute,
    required this.onNavigate,
  });

  static const Color _headerBrown = Color(0xFF3F2B23);
  static const Color _accentOrange = Color(0xFFF08F2A);

  // Shared builder for drawer navigation rows.
  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    bool highlight = false,
  }) {
    final bg = highlight ? const Color(0xFFFFD7AB) : Colors.transparent;
    final fg = highlight ? const Color(0xFFE27D19) : Colors.brown.shade400;
    return InkWell(
      // onTap: () => safeNavigate(context, route),
      onTap: () => onNavigate(route),

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: fg,
                    fontWeight:
                        highlight ? FontWeight.w600 : FontWeight.normal)),
            const Spacer(),
            if (highlight)
              const Icon(Icons.chevron_right,
                  size: 18, color: const Color(0xFFE27D19)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Drawer width tuned for tablet/desktop look (adjust as needed)
    return Drawer(
      width: 320,
      child: Container(
        color: const Color(0xFFFAF6EE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: _headerBrown,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: SafeArea(
                bottom: false,
                child: FutureBuilder<UserProfile>(
                  future: profileFuture,
                  builder: (context, snap) {
                    final profile = snap.data;
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          backgroundImage: profile?.avatarUrl != null
                              ? NetworkImage(profile!.avatarUrl!)
                              : null,
                          child: profile?.avatarUrl == null
                              ? const Icon(Icons.coffee,
                                  color: Color(0xFF6B3E2B))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile?.displayName ?? 'Express-O',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(height: 4),
                              Text(profile?.email ?? 'admin@example.com',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        // chevron
                        IconButton(
                          onPressed: () {
                            // maybe open profile detail in the future
                            onNavigate('/profile');
                          },
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.white),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),

            // content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Home (highlighted)
                      _navItem(
                          context: context,
                          icon: Icons.home,
                          label: 'Home',
                          route: '/',
                          highlight: selectedRoute == '/'),

                      const SizedBox(height: 8),
                      const Text('Store Management',
                          style: TextStyle(
                              color: Color(0xFF8E6A4A),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),

                      _navItem(
                          context: context,
                          icon: Icons.coffee_outlined,
                          label: 'Products',
                          route: '/products',
                          highlight: selectedRoute == '/products'),
                      // _navItem(
                      //     context: context,
                      //     icon: Icons.list_alt,
                      //     label: 'Categories',
                      //     route: '/categories',
                      //     highlight: selectedRoute == '/categories'),
                      _navItem(
                          context: context,
                          icon: Icons.shopping_cart_outlined,
                          label: 'Orders',
                          route: '/orders',
                          highlight: selectedRoute == '/orders'),
                      _navItem(
                          context: context,
                          icon: Icons.local_offer_outlined,
                          label: 'Discount Codes',
                          route: '/discounts',
                          highlight: selectedRoute == '/discounts'),

                      const SizedBox(height: 16),
                      const Text('Reports',
                          style: TextStyle(
                              color: Color(0xFF8E6A4A),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),

                      _navItem(
                          context: context,
                          icon: Icons.show_chart_outlined,
                          label: 'Analytics',
                          route: '/analytics',
                          highlight: selectedRoute == '/analytics'),
                      _navItem(
                          context: context,
                          icon: Icons.history,
                          label: 'Transaction History',
                          route: '/transactions',
                          highlight: selectedRoute == '/transactions'),

                      const SizedBox(height: 16),
                      const Text('More',
                          style: TextStyle(
                              color: Color(0xFF8E6A4A),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),

                      _navItem(
                          context: context,
                          icon: Icons.person_outline,
                          label: 'Profile',
                          route: '/profile',
                          highlight: selectedRoute == '/profile'),
                      _navItem(
                          context: context,
                          icon: Icons.logout,
                          label: 'Logout',
                          route: '/logout',
                          highlight: false),
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

// Placeholder routed pages used while real screens are under development.
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF5D3510),
      ),
      body: Center(
          child: Text('This is the emasdasdaderut $title page (placeholder).')),
    );
  }
}

// Legend entry model for donut chart labeling.
class _LegendEntry {
  final String label;
  final Color color;
  _LegendEntry(this.label, this.color);
}

// Container returned by _fetchDashboard with analytics + pending orders.
class _DashboardSnapshot {
  final AdminAnalyticsReport analytics;
  final List<AdminPendingOrderSummary> pending;

  _DashboardSnapshot({required this.analytics, required this.pending});
}

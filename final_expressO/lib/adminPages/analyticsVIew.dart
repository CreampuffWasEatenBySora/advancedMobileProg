import 'package:firebase_nexus/appColors.dart';
import 'package:firebase_nexus/helpers/AnalyticsSupabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import './adminHome.dart';

const brownDark = Color(0xFF3E2016);
const lightBeige = Color(0xFFF6F0E6);

class AnalyticsVIew extends StatelessWidget {
  const AnalyticsVIew({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnalyticsPage();
  }
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AdminSupabaseHelper _adminHelper = AdminSupabaseHelper();
  late Future<AdminAnalyticsReport> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _analyticsFuture = _adminHelper.fetchAnalyticsReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      appBar: AppBar(
        backgroundColor: const Color(0xFF38241D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 68, // slightly taller for breathing room
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: AdminDrawer(
        profileFuture: fetchUserProfile(), // <-- your future method

        selectedRoute: "/analytics", // mark this as active/highlighted
        onNavigate: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Column(
          children: [
            SizedBox(height: 12),
            Padding(
              padding:
                  const EdgeInsets.only(top: 12.0, left: 13.0, right: 13.0),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8), // background of TabBar
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.orange[300],
                  labelColor: const Color(0xFFE27D19),
                  unselectedLabelColor: const Color(0xFF49454F),
                  tabs: const [
                    Tab(text: 'Successful Orders'),
                    Tab(text: 'Failed Orders'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<AdminAnalyticsReport>(
                future: _analyticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load analytics',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    );
                  }
                  final report = snapshot.data!;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSuccessfulTab(report),
                        _buildFailedTab(report),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessfulTab(AdminAnalyticsReport report) {
    final categorySlices = _categoryChartSlices(report);
    return SingleChildScrollView(
      child: Column(
        children: [
          _roundedCard(
            child: Column(
              children: [
                // Donut chart using fl_chart
                SizedBox(
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: categorySlices
                              .map((d) => PieChartSectionData(
                                    value: d.y.toDouble(),
                                    color: d.color,
                                    title: '',
                                    radius: 30,
                                  ))
                              .toList(),
                          centerSpaceRadius: 60,
                          sectionsSpace: 4,
                          startDegreeOffset: -90,
                          pieTouchData: PieTouchData(enabled: false),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${report.totalOrders}',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: brownDark),
                          ),
                          const SizedBox(height: 4),
                          Text('Total Orders',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Legend row
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: categorySlices
                        .map(
                          (d) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: d.color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('${d.x} (${d.y})'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _roundedCard(
                      color: Colors.orange[600]!,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.attach_money,
                                color: Colors.white, size: 60),
                            const SizedBox(height: 12),
                            const Text(
                              'Total Sales',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              NumberFormat.currency(
                                      locale: 'en_PH', symbol: '₱')
                                  .format(report.totalSales),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _roundedCard(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.people_outline,
                                color: brownDark, size: 60),
                            const SizedBox(height: 12),
                            const Text(
                              'Total Customers',
                              style: TextStyle(color: brownDark),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${report.totalCustomers}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: brownDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Top-selling products
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: const [
                Icon(Icons.bar_chart_outlined,
                    size: 18, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text('Top-selling Products',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _roundedCard(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              child: report.topProducts.isEmpty
                  ? const SizedBox(
                      height: 60,
                      child: Center(child: Text('No sales data yet')),
                    )
                  : Column(
                      children: report.topProducts
                          .map((stat) => _productListTile(stat))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedTab(AdminAnalyticsReport report) {
    final failedOrders = report.failedOrders;
    final failedSlices = _failedChartSlices(report);
    return SingleChildScrollView(
      child: Column(
        children: [
          _roundedCard(
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: failedSlices
                              .map((d) => PieChartSectionData(
                                    value: d.y.toDouble(),
                                    color: d.color,
                                    title: '',
                                    radius: 30,
                                  ))
                              .toList(),
                          centerSpaceRadius: 60,
                          sectionsSpace: 4,
                          startDegreeOffset: -90,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${failedOrders.length}',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: brownDark),
                          ),
                          const SizedBox(height: 4),
                          Text('Failed Orders',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: failedSlices
                        .map((d) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: d.color,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(d.x),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (report.topCancellingCustomers.isNotEmpty)
            _roundedCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Cancelling Customers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: brownDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...report.topCancellingCustomers.asMap().entries.map(
                          (entry) => _topCancellingTile(
                            entry.key + 1,
                            entry.value,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ...failedOrders.map((o) => _failedOrderCard(o)),
        ],
      ),
    );
  }

  List<_ChartData> _categoryChartSlices(AdminAnalyticsReport report) {
    final stats = report.categoryStats;
    if (stats.isEmpty) {
      return [_ChartData('No data', 1, Colors.grey.shade300)];
    }
    final palette = [
      const Color(0xFFE27D19),
      const Color(0xFFFFAF5F),
      const Color(0xFFB35900),
      const Color(0xFFE7B188),
      const Color(0xFF8E5A2C),
      const Color(0xFF6F3A12),
    ];
    return List.generate(stats.length, (index) {
      final stat = stats[index];
      final label = stat.categoryName?.isNotEmpty == true
          ? stat.categoryName!
          : 'Category ${stat.categoryId}';
      return _ChartData(
        label,
        stat.itemCount,
        palette[index % palette.length],
      );
    });
  }

  List<_ChartData> _failedChartSlices(AdminAnalyticsReport report) {
    final cancelled =
        report.failedOrders.where((o) => o.status == 'Cancelled').length;
    final rejected =
        report.failedOrders.where((o) => o.status == 'Rejected').length;
    final slices = <_ChartData>[];
    if (cancelled > 0) {
      slices.add(_ChartData('Cancelled', cancelled, const Color(0xFFA42E1E)));
    }
    if (rejected > 0) {
      slices.add(_ChartData('Rejected', rejected, const Color(0xFFF0D0CB)));
    }
    return slices.isEmpty
        ? [_ChartData('No data', 1, Colors.grey.shade300)]
        : slices;
  }

  Widget _productListTile(AdminTopProductStat stat) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9E9E9), width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // soft subtle shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 1),
              color: Colors.grey[100],
            ),
            child: stat.imageUrl == null
                ? Icon(Icons.image, color: Colors.grey[400])
                : ClipOval(
                    child: Image.network(
                      stat.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              stat.name,
              style: const TextStyle(
                color: brownDark,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.05,
              ),
            ),
          ),
          Text(
            '${stat.quantitySold} sold',
            style: const TextStyle(
              color: brownDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _failedOrderCard(AdminFailedOrderInfo order) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: _roundedCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 25,
            horizontal: 16,
          ),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE27D19),
            child: Text(
              order.customerName.isNotEmpty
                  ? order.customerName.characters.first.toUpperCase()
                  : '#',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(order.customerName),
          subtitle: Text(order.itemsSummary.isEmpty
              ? 'No items captured'
              : order.itemsSummary),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statusBadge(order.status),
              const SizedBox(height: 4),
              Text(NumberFormat.currency(locale: 'en_PH', symbol: '₱')
                  .format(order.total)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topCancellingTile(int rank, AdminCustomerCancellationStat stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE27D19),
            child: Text(
              '$rank',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stat.customerName,
              style: const TextStyle(
                color: brownDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${stat.cancelledCount}x',
            style: const TextStyle(
              color: brownDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color textColor = Colors.white;
    if (status == 'Cancelled') {
      bg = const Color(0xFFF0D0CB);
      textColor = const Color(0xFFA42E1E);
    } else if (status == 'Rejected') {
      bg = const Color(0xFFF0D0CB);
      textColor = const Color(0xFFA42E1E);
    } else {
      bg = const Color(0xFFF0D0CB);
      textColor = const Color(0xFFA42E1E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
    );
  }

  /// helper to create rounded white card with elevation
  Widget _roundedCard({required Widget child, Color color = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ChartData {
  final String x;
  final num y;
  final Color color;
  _ChartData(this.x, this.y, this.color);
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
 
void main() {
  runApp(const AdminHomepage());
}
 
class AdminHomepage extends StatelessWidget {
  const AdminHomepage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFAF6EE),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardPage(),
    );
  }
}
 
//donut models
class DonutSegment {
  final String label;
  final double value;
  final Color color;
 
  DonutSegment({required this.label, required this.value, required this.color});
 
  factory DonutSegment.fromJson(Map<String, dynamic> json) {
    return DonutSegment(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      color: Color(int.parse(json['color'] ?? '0xFFF6A048')),
    );
  }
}
 
class StatsOverview {
  final double totalSales;
  final int totalCustomers;
 
  StatsOverview({required this.totalSales, required this.totalCustomers});
 
  factory StatsOverview.fromJson(Map<String, dynamic> json) => StatsOverview(
        totalSales: (json['totalSales'] as num).toDouble(),
        totalCustomers: (json['totalCustomers'] as num).toInt(),
      );
}
 
class PendingOrder {
  final String id;
  final String name;
  final String itemsSummary;
  final double price;
 
  PendingOrder(
      {required this.id,
      required this.name,
      required this.itemsSummary,
      required this.price});
 
  factory PendingOrder.fromJson(Map<String, dynamic> json) => PendingOrder(
        id: json['id'] as String,
        name: json['name'] as String,
        itemsSummary: json['itemsSummary'] as String,
        price: (json['price'] as num).toDouble(),
      );
}
 
class DashboardData {
  final List<DonutSegment> donutSegments;
  final int totalOrders;
  final StatsOverview stats;
  final List<PendingOrder> pendingOrders;
 
  DashboardData(
      {required this.donutSegments,
      required this.totalOrders,
      required this.stats,
      required this.pendingOrders});
 
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final donut = (json['donut'] as List<dynamic>)
        .map((e) => DonutSegment.fromJson(e as Map<String, dynamic>))
        .toList();
    final stats = StatsOverview.fromJson(json['stats'] as Map<String, dynamic>);
    final pending = (json['pendingOrders'] as List<dynamic>)
        .map((e) => PendingOrder.fromJson(e as Map<String, dynamic>))
        .toList();
    return DashboardData(
        donutSegments: donut,
        totalOrders: (json['totalOrders'] as num).toInt(),
        stats: stats,
        pendingOrders: pending);
  }
}
 
class DummyData {
  // Example JSON structure returned from backend
  static const _sampleJson = '''
  {
    "donut": [
      {"label": "Coffee", "value": 55, "color": "0xFFF09425"},
      {"label": "Pastry", "value": 25, "color": "0xFFF6B57D"},
      {"label": "Others", "value": 20, "color": "0xFF8E4B0E"}
    ],
    "totalOrders": 65,
    "stats": {"totalSales": 2500, "totalCustomers": 70},
    "pendingOrders": [
      {"id": "ORD123", "name": "Ruel Escano", "itemsSummary": "Matcha Latte, Chocolate Croissant", "price": 240},
      {"id": "ORD124", "name": "Anna Cruz", "itemsSummary": "Americano", "price": 120}
    ]
  }
  ''';
 
  // Simulate network delay
  static Future<DashboardData> fetchDashboard() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final parsed = json.decode(_sampleJson) as Map<String, dynamic>;
    return DashboardData.fromJson(parsed);
  }
}
 
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
 
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
 
class _DashboardPageState extends State<DashboardPage> {
  late Future<DashboardData> _dashboardFuture;
 
  @override
  void initState() {
    super.initState();
    _loadData();
  }
 
  void _loadData() {
    _dashboardFuture = DummyData.fetchDashboard();
  }
 
  @override
  Widget build(BuildContext context) {
    const safePadding = 16.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: safePadding),
          child: FutureBuilder<DashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error: \${snapshot.error}'));
              }
              final data = snapshot.data!;
 
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildTopBar(),
                    const SizedBox(height: 12),
                    _buildDonutCard(data),
                    const SizedBox(height: 16),
                    _buildShortcutsRow(),
                    const SizedBox(height: 18),
                    _buildStatisticsOverview(data),
                    const SizedBox(height: 18),
                    _buildPendingOrders(data),
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
 
  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        const SizedBox(width: 6),
        const Text('Hello, Admiasasn',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFF08F2A),
          child: Text('AD',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
 
  Widget _buildDonutCard(DashboardData data) {
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
                    child: Center(child: _buildDonutChart(data)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: data.donutSegments
                  .map((seg) => _buildLegendItem(seg))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
 
  Widget _buildLegendItem(DonutSegment seg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: seg.color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(seg.label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
 
  Widget _buildDonutChart(DashboardData data) {
    final total = data.donutSegments.fold<double>(0.0, (p, e) => p + e.value);
    const showCenterText = true;
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 46,
            sections: data.donutSegments.map((seg) {
              final percentage = total == 0 ? 0 : (seg.value / total) * 100;
              return PieChartSectionData(
                value: seg.value,
                radius: 46,
                showTitle: false,
                color: seg.color,
              );
            }).toList(),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${data.totalOrders}',
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
 
  Widget _buildShortcutsRow() {
    final items = [
      _ShortcutItem(icon: Icons.person_outline, label: 'Customers'),
      _ShortcutItem(icon: Icons.coffee_outlined, label: 'Products'),
      _ShortcutItem(icon: Icons.receipt_long, label: 'Orders'),
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
 
  Widget _buildShortcutCard(_ShortcutItem item) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Tapped ${item.label}'))),
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
 
  Widget _buildStatisticsOverview(DashboardData data) {
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
                    borderRadius: BorderRadius.circular(12)),
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
                          Text('₱ ${data.stats.totalSales.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
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
                          Text('${data.stats.totalCustomers}',
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
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
 
  Widget _buildPendingOrders(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Pending Orders',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('· ${data.pendingOrders.length}',
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: data.pendingOrders
              .map((ord) => _buildPendingOrderCard(ord))
              .toList(),
        ),
      ],
    );
  }
 
  Widget _buildPendingOrderCard(PendingOrder ord) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        title: Row(
          children: [
            Expanded(
                child: Text(ord.name,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Text('₱ ${ord.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF5D3510))),
          ],
        ),
        subtitle: Text('${ord.id} • ${ord.itemsSummary}',
            style: const TextStyle(color: Colors.black45)),
        onTap: () => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Open order ${ord.id}'))),
      ),
    );
  }
}
 
class _ShortcutItem {
  final IconData icon;
  final String label;
  _ShortcutItem({required this.icon, required this.label});
}
 
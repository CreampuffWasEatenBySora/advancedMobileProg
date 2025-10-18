import 'dart:math';
import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/widgets/loading_screens.dart';
import 'package:flutter/material.dart';
import 'package:firebase_nexus/appColors.dart';
import '../adminHome.dart'; // adjust path depending on your folder structure

import './discountView.dart';
import './discountAdd.dart';
import './discountEdit.dart';

// ---------- STATUS BADGE ----------
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Map<String, Color> _getColors(String status) {
    switch (status) {
      case 'Active':
        return {
          'bg': const Color(0xFFCBF0D8),
          'text': const Color(0xFF1EA44B),
        };
      case 'Expired':
        return {
          'bg': const Color(0xFFFFE0E0),
          'text': const Color(0xFFD32F2F),
        };
      default:
        return {
          'bg': const Color(0xFFEDEDED),
          'text': const Color(0xFF333333),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w600,
          color: colors['text'],
          fontSize: 12,
        ),
      ),
    );
  }
}

// ---------- DISCOUNT CARD ----------
class DiscountCard extends StatelessWidget {
  final int id;
  final IconData icon;
  final String desc;
  final String discountCode;
  final String discountType;
  final String description;
  final String status;
  final String displayValue;
  final num value;
  final int usage_limit;
  final DateTime start_date;
  final DateTime expiry_date;
  final DateTime createdAt;
  final bool isActive;

  const DiscountCard({
    super.key,
    required this.id,
    required this.icon,
    required this.desc,
    required this.discountCode,
    required this.discountType,
    required this.usage_limit,
    required this.description,
    required this.value,
    required this.displayValue,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.start_date,
    required this.expiry_date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(13), // spacing around icon
              decoration: const BoxDecoration(
                color: Color(0xFFF8F2E2), // background color
                shape: BoxShape.circle, // makes it circular
              ),
              child: Icon(
                icon,
                size: 24, // smaller so it fits nicely inside circle
                color: AppColors.secondaryVariant,
              ),
            ),

            const SizedBox(width: 12),

            // Middle Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${discountCode}: ${displayValue} OFF',
                      style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.secondary)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          color: AppColors.input)),
                  const SizedBox(height: 6),
                  Text(
                    "Created ${DateTime.now().difference(createdAt).inHours}h ago",
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.input,
                        fontFamily: 'Quicksand'),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: status),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF2c1d16)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiscountEdit(
                              id: id,
                              code: discountCode,
                              desc: desc,
                              type: discountType,
                              value: value,
                              usage_limit: usage_limit,
                              start_date: start_date,
                              expiry_date: expiry_date,
                              isActive: isActive,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class DiscountListPage extends StatefulWidget {
  const DiscountListPage({super.key});

  @override
  State<DiscountListPage> createState() => _DiscountListPageState();
}

class _DiscountListPageState extends State<DiscountListPage> {
  final supabaseHelper = AdminSupabaseHelper();
  bool _loading = true;
  List<Map<String, dynamic>> _discounts = [];

  Future<UserProfile> fetchUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserProfile(
      displayName: 'Express-O',
      email: 'admin123@gmail.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?...',
    );
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final discounts = await supabaseHelper.getAll("Discounts", null, null);
      setState(() {
        _discounts = discounts;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching discounts: $e");
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
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: const Text(
          "Discount Codes",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      drawer: AdminDrawer(
        profileFuture: fetchUserProfile(),
        selectedRoute: "/discounts",
        onNavigate: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const discountAdd()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _discounts.isEmpty
          ? const Center(
              child: Text(
                "No discounts found.",
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _discounts.length,
              itemBuilder: (context, index) {
                final discount = _discounts[index];

                final type = discount['type'] ?? 'fixed';
                final value = discount['value'];
                final displayValue = type == 'percentage'
                    ? "${discount['value']}%"
                    : "₱${discount['value']}";
                final code = discount['code'] ?? "N/A";
                final desc = discount['desc'] ?? "";
                final isActive = discount['isActive'] ?? false;
                final createdAt = DateTime.tryParse(
                        discount['start_date'] ?? DateTime.now().toString()) ??
                    DateTime.now();

                String status;
                if (!isActive) {
                  status = "Inactive";
                } else {
                  final expiryDate =
                      DateTime.tryParse(discount['expiry_date'] ?? '') ??
                          DateTime.now();
                  status = expiryDate.isBefore(DateTime.now())
                      ? "Expired"
                      : "Active";
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiscountViewPage(discountCode: code),
                      ),
                    );
                  },
                  child: DiscountCard(
                    id: discount['id'],
                    icon: Icons.local_offer,
                    discountType: type,
                    value: value,
                    displayValue: displayValue,
                    desc: desc,
                    isActive: discount['isActive'],
                    discountCode: code,
                    description: desc,
                    status: status,
                    createdAt: createdAt,
                    usage_limit: discount['usage_limit'],
                    start_date: DateTime.tryParse(discount['start_date'] ??
                            DateTime.now().toString()) ??
                        DateTime.now(),
                    expiry_date: DateTime.tryParse(discount['expiry_date'] ??
                            DateTime.now().toString()) ??
                        DateTime.now(),
                  ),
                );
              },
            ),
    );
  }
}

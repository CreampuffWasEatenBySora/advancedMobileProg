import 'package:firebase_nexus/adminPages/adminHome.dart';
import 'package:firebase_nexus/adminPages/analyticsVIew.dart';
import 'package:firebase_nexus/adminPages/orderPages/orderView.dart';
import 'package:firebase_nexus/adminPages/productsView.dart';
import 'package:firebase_nexus/providers/navigation_provider.dart';
import 'package:firebase_nexus/widgets/admin_bottom_nav..dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final pages = [
      const AdminHome(),
      const AdminProducts(),
      const AdminOrderPages(),
      const AnalyticsVIew(),
    ];

    return Scaffold(
      body: pages[navProvider.selectedIndex],
      // bottomNavigationBar: const AdminBottomNav(),
    );
  }
}

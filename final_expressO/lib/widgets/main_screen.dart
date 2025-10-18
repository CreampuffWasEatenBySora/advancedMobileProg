import 'package:firebase_nexus/Profile/ShowProfile.dart';
import 'package:firebase_nexus/adminPages/dummyCart.dart';
import 'package:firebase_nexus/providers/navigation_provider.dart';
import 'package:firebase_nexus/providers/userProvider.dart';
import 'package:firebase_nexus/views/UserProducts.dart';
import 'package:firebase_nexus/views/checkout_user.dart';
import 'package:firebase_nexus/views/dummyCart.dart';
import 'package:firebase_nexus/views/dummyCartSupa.dart';
import 'package:firebase_nexus/views/MyHomePage.dart';
import 'package:firebase_nexus/views/user_OrderPages/CartList.dart';
import 'package:firebase_nexus/views/user_profilePages/userProfile.dart';
import 'package:firebase_nexus/views/user_OrderPages/orderList.dart';

import 'package:firebase_nexus/widgets/app_bottom_nav.dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final pages = [
      const MyHomePage(),
      const NeilCart(),
      OrderListPage(
        user: user,
      ),
      // const DummyOrderPage(),
      // const SQLitePage(),
      // const SupaPage(),

      const UserProfilePage(),
    ];

    return Scaffold(
      body: pages[navProvider.selectedIndex],
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}

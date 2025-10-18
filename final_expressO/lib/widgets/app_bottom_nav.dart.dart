import 'package:firebase_nexus/appColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF), // 🔹 Unselected background color
      ),
      child: BottomNavigationBar(
        backgroundColor:
            Colors.transparent, // transparent, handled by container
        elevation: 0, // remove shadow
        currentIndex: navProvider.selectedIndex,
        onTap: (index) => navProvider.setIndex(index),
        selectedItemColor: const Color(0xFF603B17), // Selected item color
        unselectedItemColor:
            const Color(0xFF603B17).withOpacity(0.5), // Lighter unselected
        type: BottomNavigationBarType.fixed, // Prevent shifting
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              navProvider.selectedIndex == 0 ? Icons.home : Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              navProvider.selectedIndex == 1
                  ? Icons.fastfood
                  : Icons.fastfood_outlined,
            ),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              navProvider.selectedIndex == 2
                  ? Icons.coffee
                  : Icons.coffee_outlined,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              navProvider.selectedIndex == 3
                  ? Icons.person
                  : Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

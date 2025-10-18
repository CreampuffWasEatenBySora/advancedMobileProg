import 'package:firebase_nexus/appColors.dart';
import 'package:firebase_nexus/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOrderPages extends StatelessWidget {
  const AdminOrderPages({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text(
          "Store Orders",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 10, // Dummy length
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item #$index'),
            subtitle: Text('Provider value: ${navProvider.selectedIndex}'),
          );
        },
      ),
    );
  }
}

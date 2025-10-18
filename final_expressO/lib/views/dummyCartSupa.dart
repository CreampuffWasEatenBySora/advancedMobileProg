import 'package:firebase_nexus/appColors.dart';
import 'package:firebase_nexus/helpers/supabase_helper.dart';
import 'package:firebase_nexus/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';

class SupaPage extends StatefulWidget {
  const SupaPage({super.key});

  @override
  State<SupaPage> createState() => _SupaPageState();
}

class _SupaPageState extends State<SupaPage> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final db = context.read<SupabaseHelper>();
    final rows = await db.getAll("products");
    return rows.map((row) => Product.fromJson(row)).toList();
  }

  Future<void> _addDummyProduct() async {
    final db = context.read<SupabaseHelper>();

    final dummy = Product(
      name: "Item ${DateTime.now().millisecondsSinceEpoch}",
      price: 199.99,
      quantity: 1,
    );

    await db.insert("products", dummy.toJson());

    setState(() {
      _futureProducts = _fetchProducts();
    });
  }

  Future<void> _deleteProduct(int id) async {
    final db = context.read<SupabaseHelper>();
    await db.delete("products", "id", id);

    setState(() {
      _futureProducts = _fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text(
          "Your Cart",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No items in cart"));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondary.withOpacity(0.2),
                  child: Text(product.name[0].toUpperCase()),
                ),
                title: Text(product.name),
                subtitle: Text(
                  "₱${product.price.toStringAsFixed(2)}\nProvider value: ${navProvider.selectedIndex}",
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(product.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: _addDummyProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:io';
import 'package:firebase_nexus/adminPages/AddProduct.dart';
import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/widgets/loading_overlay.dart';
import 'package:firebase_nexus/widgets/loading_screens.dart';
import 'package:flutter/material.dart';

class Editproductflow extends StatefulWidget {
  final int productID;
  const Editproductflow({super.key, required this.productID});

  @override
  State<Editproductflow> createState() => _EditproductflowState();
}

class _EditproductflowState extends State<Editproductflow> {
  int _currentStep = 1;
  bool _loading = true;
  bool _success = false;
  String? _error;
  bool _submitLoading = false;
  bool _initialized = false;

  final supabaseHelper = AdminSupabaseHelper();

  // Shared draft state across steps
  Map<String, dynamic> productDraft = {
    "productName": "",
    "description": "",
    "productImage": null,
    "category": null,
    "stock": 0,
    "status": "Available",
    "variations": [],
    "final": false,
    "newImg": false,
  };

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    print('INITIAL STATE METHOD');

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      if (_initialized) return;
      _initialized = true;

      final categories = await supabaseHelper.getAll("Categories",null,null);
      final editedProduct =
          await supabaseHelper.getById("Products", 'id', widget.productID);

      print("editedProduct printed!");
      print(editedProduct);

      if (editedProduct != null && editedProduct['img'] == null) {
        setState(() {
          productDraft["category"] = editedProduct["cat_id"].toString();
          productDraft["productName"] = editedProduct["name"];
          productDraft["description"] = editedProduct["desc"];
          productDraft["stock"] = editedProduct["stock"];
          productDraft["status"] = editedProduct["status"];
          productDraft["variations"] = editedProduct["variations"];
          _categories = categories;
          _loading = false;
        });
      } else if (editedProduct != null && editedProduct['img'] != null) {
        final file = await fileFromSupabase(editedProduct['img']);

        setState(() {
          productDraft["category"] = editedProduct["cat_id"].toString();
          productDraft["productName"] = editedProduct["name"];
          productDraft["description"] = editedProduct["desc"];
          productDraft["productImage"] = file;
          productDraft["stock"] = editedProduct["stock"];
          productDraft["status"] = editedProduct["status"];
          productDraft["variations"] = editedProduct["variations"];
          _categories = categories;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error fetching initial state: $e");
      setState(() => _loading = false);
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
  }

  void _updateDraft(Map<String, dynamic> updates) {
    setState(() {
      productDraft.addAll(updates);
    });
  }

  void _confirmSuccess() {
    setState(() {
      _success = true;
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Product added successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/products', (r) => false);
  }

  Future<void> _finalSubmit() async {
    setState(() => _submitLoading = true);

    try {
      print('---------------------- FINAL SUBMIT ----------------------');

      // Extract values from draft
      final productID = widget.productID.toString();
      final productName = productDraft["productName"];
      final description = productDraft["description"];
      final category = productDraft["category"];
      final stock = productDraft["stock"];
      final status = productDraft["status"];
      final variations = productDraft["variations"];
      final imageFile = productDraft["productImage"];
      final newImage = productDraft["newImg"];

      // Prepare data map
      final Map<String, dynamic> updateData = {
        "name": productName,
        "desc": description,
        "cat_id": int.tryParse(category ?? _categories.first['id']),
        "stock": stock,
        "status": status,
        "variations": variations,
      };

      // If a new image (File) is selected, upload and include URL
      if (newImage as bool && imageFile is File) {
        final newImageUrl =
            await supabaseHelper.uploadProductImage(imageFile, productID);
        if (newImageUrl != null) {
          updateData["img"] = newImageUrl;
        } else {
          throw Exception("Failed to upload product image");
        }
      }

      print('Updating product with data: $updateData');

      // Perform the update
      final result =
          await supabaseHelper.update("Products", "id", productID, updateData);

      if (result['status'] == 'success') {
        print('✅ Product updated successfully');
        _confirmSuccess();
      } else {
        print('❌ Update failed: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error submitting final submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _submitLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return const Center(child: Text('Product Successfully added!'));
    }

    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Main content stays in memory even while loading
            _currentStep == 1 && !(_loading || _submitLoading)
                ? AddProductStep1(
                    editMode: true,
                    key: const ValueKey(1),
                    draft: productDraft,
                    onNext: (updates) {
                      _updateDraft(updates);
                      _goToStep(2);
                    },
                    onCancel: () => Navigator.pop(context),
                  )
                : AddProductStep2(
                    editMode: true,
                    key: const ValueKey(2),
                    draft: productDraft,
                    categories: _categories,
                    onBack: () => _goToStep(1),
                    onFinalize: (updates) {
                      _updateDraft(updates);
                      debugPrint("FINAL PRODUCT DRAFT: $productDraft");
                      if (productDraft['final']) {
                        debugPrint("FINAL DETECTED!!!!!");
                        setState(() => _submitLoading = true);
                        _finalSubmit();
                      } else {
                        debugPrint("T o T");
                      }
                    },
                  ),

            // 🔶 LOADING OVERLAY
            if (_loading || _submitLoading || _error != null)
              LoadingScreens(
                message: _error != null
                    ? _error!
                    : _loading
                        ? 'Loading product setup...'
                        : 'Submitting your product to the database...',
                error: _error != null,
                onRetry: _error != null
                    ? () {
                        Navigator.pop(context);
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

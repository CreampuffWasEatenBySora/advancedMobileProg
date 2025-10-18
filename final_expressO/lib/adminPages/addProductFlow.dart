import 'dart:io';
import 'package:firebase_nexus/adminPages/AddProduct.dart';
import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/widgets/loading_overlay.dart';
import 'package:firebase_nexus/widgets/loading_screens.dart';
import 'package:flutter/material.dart';

class AddProductFlow extends StatefulWidget {
  const AddProductFlow({super.key});

  @override
  State<AddProductFlow> createState() => _AddProductFlowState();
}

class _AddProductFlowState extends State<AddProductFlow> {
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

      setState(() {
        if (categories.isNotEmpty) {
          productDraft["category"] = categories.first["id"].toString();
        }
        _categories = categories;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
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
    try {
      print(
          '--------------------------------------------------------------------------------------------');

      final response = await supabaseHelper.insert('Products', {
        'cat_id': productDraft['category'],
        'name': productDraft['productName'],
        'desc': productDraft['description'],
        'stock': productDraft['stock'],
        'status': productDraft['status'],
        'variations': productDraft['variations'],
      });

      print(response);
      print(response['data']['id']);

      if (response['status'] != 'success') {
        setState(() {
          _submitLoading = false;
          _error = response['message'];
        });
        return;
      }

      final imgResponse = await supabaseHelper.uploadProductImage(
          productDraft['productImage'], response['data']['id'].toString());
      print(imgResponse);

      if (imgResponse == null) {
        setState(() {
          _submitLoading = false;
          _error = 'Image upload failed!';
        });
        return;
      }
      print(response['data']['id']);
      print({'img': imgResponse});
      final updateResponse = await supabaseHelper.update('Products', 'id',
          response['data']['id'].toString(), {'img': imgResponse});
      print(updateResponse);

      if (updateResponse['status'] != 'success') {
        setState(() {
          _submitLoading = false;
          _error = response['message'];
        });
        return;
      } else {
        _confirmSuccess();
      }
    } catch (e) {
      print("Error submitting final submit: $e");
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
            _currentStep == 1
                ? AddProductStep1(
                    editMode: false,
                    key: const ValueKey(1),
                    draft: productDraft,
                    onNext: (updates) {
                      _updateDraft(updates);
                      _goToStep(2);
                    },
                    onCancel: () => Navigator.pop(context),
                  )
                : AddProductStep2(
                    key: const ValueKey(2),
                    editMode: false,
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

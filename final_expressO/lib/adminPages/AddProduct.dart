import 'dart:convert';

import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:firebase_nexus/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AppColors {
  static const Color primaryBrown = Color(0xFF4B2E19);
  static const Color accentOrange = Color(0xFFF08F2A);
  static const Color background = Color(0xFFFAF6EE);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF666666);
}

class AddProductStep1 extends StatefulWidget {
  final Map<String, dynamic> draft;
  final void Function(Map<String, dynamic> updatedDraft) onNext;
  final VoidCallback onCancel;
  final bool editMode;

  const AddProductStep1({
    super.key,
    required this.draft,
    required this.onNext,
    required this.onCancel,
    required this.editMode,
  });

  @override
  State<AddProductStep1> createState() => _AddProductStep1State();
}

class _AddProductStep1State extends State<AddProductStep1> {
  late bool _editMode;
  late bool _newImage;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    print("widget.draft printed!");
    print(widget.draft);
    _newImage = widget.draft["newImg"] ?? false;
    _selectedImage = widget.draft["productImage"];
    _editMode = widget.editMode;
    _nameController =
        TextEditingController(text: widget.draft["productName"] ?? "");
    _descriptionController =
        TextEditingController(text: widget.draft["description"] ?? "");
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 80,
    );

    if (image != null) {
      if (_editMode) {
        setState(() {
          _newImage = true;
          _selectedImage = File(image.path);
        });
      } else {
        setState(() => _selectedImage = File(image.path));
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearImage() => setState(() => _selectedImage = null);

  void _handleNext() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedDraft = {
      ...widget.draft,
      "productName": _nameController.text,
      "description": _descriptionController.text,
      "productImage": _selectedImage,
      "newImg": _newImage,
    };

    widget.onNext(updatedDraft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF38241D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 68, // slightly taller for breathing room
        elevation: 0,
        title: Text(
          _editMode ? "Edit Product" : "Add Product",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Step 1 of 2",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              radius: 14,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                                onPressed: _clearImage,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 45, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "Upload Product Image",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 25),
            _buildTextField(
              controller: _nameController,
              label: "Product Name",
              hint: "Enter product name",
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: "Description",
              hint: "Write your product description here...",
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: AppColors.accentOrange, width: 2),
                    ),
                    child: TextButton(
                      onPressed: widget.onCancel,
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.primaryBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentOrange, Color(0xFFFFA726)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: TextButton(
                      onPressed: _handleNext,
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.darkGrey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          alignLabelWithHint: maxLines > 1,
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AddProductStep2 extends StatefulWidget {
  final Map<String, dynamic> draft;
  final List<Map<String, dynamic>> categories;
  final void Function(Map<String, dynamic> updates) onFinalize;
  final VoidCallback onBack;
  final bool editMode;

  const AddProductStep2({
    super.key,
    required this.draft,
    required this.categories,
    required this.onFinalize,
    required this.onBack,
    required this.editMode,
  });

  @override
  State<AddProductStep2> createState() => _AddProductStep2State();
}

class _AddProductStep2State extends State<AddProductStep2> {
  late String _status;
  late bool _editMode;
  String? _selectedCategory;
  late TextEditingController _stockController;
  List<Map<String, dynamic>> _variations = [];

  final supabaseHelper = AdminSupabaseHelper();

  @override
  void initState() {
    super.initState();
    _editMode = widget.editMode;
    _status = widget.draft["status"] ?? "Available";
    _stockController = TextEditingController(
      text: widget.draft["stock"]?.toString() ?? '',
    );
    _variations = List<Map<String, dynamic>>.from(
      widget.draft["variations"] ?? [],
    );
    _selectedCategory = widget.draft['category'];
  }

  bool _validateProduct() {
    final stock = int.parse(_stockController.text);
    final variations = _variations;

    // Check stock
    if (stock == 0 && _status != 'Out of stock') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Choose 'Out of stock' if zero stock!"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check stock
    if (stock != 0 && _status == 'Out of stock') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("'Out of stock' is invalid when stock isn't zero!"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check zero-price variations
    if (variations.isNotEmpty) {
      for (var variation in variations) {
        final price = variation["price"] ?? 0;
        if (price == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("One or more variations have a price of 0."),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }
    }

    return true; // ✅ passed all checks
  }

  void _handleFinalize() {
    if (_validateProduct()) {
      final updatedDraft = {
        "status": _status,
        "category": _selectedCategory,
        "stock": int.tryParse(_stockController.text) ?? 0,
        "variations": _variations,
        "final": true,
      };

      widget.onFinalize(updatedDraft);
    }
  }

  void _handleBack() {
    final updatedDraft = {
      "status": _status,
      "category": _selectedCategory,
      "stock": int.tryParse(_stockController.text) ?? 0,
      "variations": _variations,
      "final": false,
    };

    widget.onFinalize(updatedDraft);

    widget.onBack(); // Go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF38241D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        toolbarHeight: 68, // slightly taller for breathing room
        elevation: 0,
        title: Text(
          _editMode ? "Edit Product" : "Add Product",
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
              fontSize: 16,
              color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Step 2 of 2",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.darkGrey),
            ),
            const SizedBox(height: 25),

            _buildDropdown<String>(
              label: "Category",
              value: _selectedCategory,
              items: widget.categories,
              valueKey: 'id',
              labelKey: 'name',
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),

            const SizedBox(height: 16),

            // Stock
            _buildTextField(
              controller: _stockController,
              label: "Stock",
              hint: "0",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Variations Editor
            SizedBox(
              height: 220,
              child: VariationEditor(
                variations: _variations,
                onChanged: (updated) => setState(() => _variations = updated),
              ),
            ),
            const SizedBox(height: 20),

            // Status Dropdown
            _buildDropdown<String>(
              label: "Status",
              value: _status,
              items: const [
                {'id': "Available", 'name': "Available"},
                {'id': "Inactive", 'name': "Inactive"},
                {'id': "Out of stock", 'name': "Out of stock"},
              ],
              valueKey: 'id',
              labelKey: 'name',
              onChanged: (val) => setState(() => _status = val!),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: AppColors.accentOrange, width: 2),
                    ),
                    child: TextButton(
                      onPressed: _handleBack,
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentOrange, Color(0xFFFFA726)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: TextButton(
                      onPressed: _handleFinalize,
                      child: const Text(
                        "Finalize Product",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<Map<String, dynamic>> items,
    required String valueKey, // e.g. 'id'
    required String labelKey, // e.g. 'name'
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item[valueKey].toString() as T,
                  child: Text(
                    item[labelKey],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: AppColors.darkGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelText: label,
          labelStyle: const TextStyle(
            color: AppColors.darkGrey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class VariationEditor extends StatefulWidget {
  final List<Map<String, dynamic>> variations;
  final Function(List<Map<String, dynamic>>) onChanged;

  const VariationEditor({
    super.key,
    required this.variations,
    required this.onChanged,
  });

  @override
  State<VariationEditor> createState() => _VariationEditorState();
}

class _VariationEditorState extends State<VariationEditor> {
  late List<Map<String, dynamic>> _variations;

  final List<Map<String, dynamic>> _defaultVariations = [
    {'name': 'Small', 'price': null},
    {'name': 'Medium', 'price': null},
    {'name': 'Large', 'price': null},
  ];

  @override
  void initState() {
    super.initState();
    _variations = List<Map<String, dynamic>>.from(widget.variations);

    if (_variations.isEmpty) {
      _variations = _defaultVariations;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(_variations);
      });
    }
  }

  void _addVariation() {
    _openVariationDialog(index: null);
  }

  void _removeVariation(int index) {
    setState(() {
      _variations.removeAt(index);
      widget.onChanged(_variations);
    });
  }

  void _openVariationDialog({int? index}) {
    final bool isEditing = index != null;
    final variation = isEditing
        ? Map<String, dynamic>.from(_variations[index!])
        : {'name': '', 'price': null};

    final nameController = TextEditingController(text: variation['name']);
    final priceController = TextEditingController(
      text: variation['price']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Variation' : 'Add Variation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Variation name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price (₱)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            if (isEditing)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _removeVariation(index!);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.trim());

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a variation name.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() {
                  if (isEditing) {
                    _variations[index!] = {'name': name, 'price': price};
                  } else {
                    _variations.add({'name': name, 'price': price});
                  }
                  widget.onChanged(_variations);
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
              ),
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Text(
                "Size Variations",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.darkGrey,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _addVariation,
                icon:
                    const Icon(Icons.add_circle, color: AppColors.accentOrange),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Scrollable variation list
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 300, maxHeight: 450),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _variations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final variation = _variations[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${variation['name']} — ₱${variation['price']?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: AppColors.accentOrange),
                          onPressed: () => _openVariationDialog(index: index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

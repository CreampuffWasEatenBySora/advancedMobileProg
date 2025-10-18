import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:flutter/material.dart';

class Category {
  String? id;
  String name;
  int iconIndex;
  Category({this.id, required this.name, required this.iconIndex});
}

class CategoryLateral extends StatefulWidget {
  final Function(Category category) onSaveCategory;
  final List<Category> initialCategories;

  const CategoryLateral({
    super.key,
    required this.onSaveCategory,
    this.initialCategories = const [],
  });

  @override
  State<CategoryLateral> createState() => _CategoryLateralState();
}

class _CategoryLateralState extends State<CategoryLateral> {
  List<Category> categories = [];
  bool _loading = true;
  bool _actionLoading = false; // 👈 new: for insert/update/delete lock
  final TextEditingController _categoryNameController = TextEditingController();
  final supabaseHelper = AdminSupabaseHelper();
  int _selectedIconIndex = 0;

  final List<IconData> availableIcons = [
    Icons.fastfood,
    Icons.local_fire_department,
    Icons.local_bar,
    Icons.coffee,
    Icons.ramen_dining,
    Icons.set_meal,
    Icons.wine_bar,
    Icons.apple,
    Icons.local_drink,
    Icons.lunch_dining,
    Icons.bakery_dining,
    Icons.spa,
    Icons.icecream,
    Icons.rice_bowl,
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final fetchedCategories =
          await supabaseHelper.getAll("Categories", null, null);

      setState(() {
        _loading = false;
        categories = fetchedCategories
            .map((e) => Category(
                  id: e['id']?.toString(),
                  name: e['name'] ?? '',
                  iconIndex: e['icon'],
                ))
            .toList();
      });
    } catch (e) {
      print("Error fetching categorieasassas: $e");
      setState(() => _loading = false);
    }
  }

  bool canDeleteCategory(Category category) {
    return true; // 👈 plug in your real check later
  }

  Future<void> _saveCategory({Category? category, int? editIndex}) async {
    final name = _categoryNameController.text.trim();
    if (name.isEmpty) return;

    final data = {
      'name': name,
      'icon': _selectedIconIndex,
    };

    setState(() => _actionLoading = true);

    try {
      if (category == null) {
        // INSERT
        final res = await supabaseHelper.insert('Categories', data);
        final newCategory = Category(
          id: res['id'].toString(),
          name: name,
          iconIndex: _selectedIconIndex,
        );
        setState(() => categories.add(newCategory));
      } else {
        // UPDATE
        await supabaseHelper.update('Categories', 'id', category.id!, data);
        setState(() {
          categories[editIndex!] = Category(
              id: category.id, name: name, iconIndex: _selectedIconIndex);
        });
      }

      Navigator.of(context).pop();
      _categoryNameController.clear();
    } catch (e) {
      print("Error saving category: $e");
    } finally {
      setState(() => _actionLoading = false);
    }
  }

  Future<void> _deleteCategory(Category category, int index) async {
    setState(() => _actionLoading = true);
    try {
      await supabaseHelper.delete('Categories', 'id', category.id);
      setState(() => categories.removeAt(index));
    } catch (e) {
      print("Error deleting category: $e");
    } finally {
      setState(() => _actionLoading = false);
    }
  }

  void _showAddEditCategoryDialog({Category? category, int? editIndex}) {
    if (category != null) {
      _categoryNameController.text = category.name;
      _selectedIconIndex = category.iconIndex;
    } else {
      _categoryNameController.clear();
      _selectedIconIndex = 0;
    }

    showDialog(
      context: context,
      barrierDismissible: !_actionLoading,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category == null ? 'Add Category' : 'Edit Category',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                        color: Color(0xFF38241D)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a category to keep your menu organized.',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                        color: Color(0xFF8E4B0E)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _categoryNameController,
                    enabled: !_actionLoading,
                    decoration: InputDecoration(
                      hintText: 'Category Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE7D3B4)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose Icon',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                        color: Color(0xFF38241D)),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: availableIcons.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIconIndex == index;
                      return GestureDetector(
                        onTap: _actionLoading
                            ? null
                            : () {
                                setDialogState(() {
                                  _selectedIconIndex = index;
                                });
                              },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE27D19)
                                : const Color(0xFFF5F3F0),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? null
                                : Border.all(color: const Color(0xFFE7D3B4)),
                          ),
                          child: Icon(
                            availableIcons[index],
                            color: isSelected ? Colors.white : Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _actionLoading
                              ? null
                              : () => _saveCategory(
                                  category: category, editIndex: editIndex),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE27D19),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _actionLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _actionLoading
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  _categoryNameController.clear();
                                  _selectedIconIndex = 0;
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Quicksand',
                              color: Color(0xFF8E4B0E),
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
        });
      },
    );
  }

  Widget _buildCategoryItem(Category category, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              availableIcons[category.iconIndex],
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Quicksand',
                color: Color(0xFF38241D),
              ),
            ),
          ),
          IconButton(
            onPressed: _actionLoading
                ? null
                : () => _showAddEditCategoryDialog(
                    category: category, editIndex: index),
            icon: const Icon(Icons.edit_outlined,
                color: Color(0xFF8E4B0E), size: 20),
          ),
          IconButton(
            onPressed: _actionLoading
                ? null
                : () {
                    if (!canDeleteCategory(category)) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text("Cannot Delete"),
                          content: Text(
                              "This category has products assigned and cannot be deleted."),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Category"),
                        content: Text(
                            "Are you sure you want to delete '${category.name}'?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteCategory(category, index);
                            },
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: Color(0xFFF5F3F0)),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(color: Color(0xFF38241D)),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.chevron_left,
                                    color: Colors.white, size: 28),
                              ),
                              const Expanded(
                                child: Text(
                                  'Categories',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _actionLoading
                                    ? null
                                    : () => _showAddEditCategoryDialog(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE27D19),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) =>
                              _buildCategoryItem(categories[index], index),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Trigger function
void showCategoryLateral(
    BuildContext context, Function(Category) onSaveCategory) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return CategoryLateral(onSaveCategory: onSaveCategory);
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(CurvedAnimation(
          parent: animation1,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}

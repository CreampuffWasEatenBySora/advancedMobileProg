import 'package:flutter/material.dart';
import 'package:firebase_nexus/appColors.dart';

class EditProfileModal extends StatefulWidget {
  final Map<String, dynamic> user;
  final Future<void> Function(Map<String, dynamic>)?
      onSave; // optional async save

  const EditProfileModal({
    super.key,
    required this.user,
    this.onSave,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController nameController;
  // late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['name'] ?? '');
    // emailController = TextEditingController(text: widget.user['email'] ?? '');
    addressController =
        TextEditingController(text: widget.user['address'] ?? '');
    phoneController =
        TextEditingController(text: widget.user['phone_number'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    // emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = {
      'name': nameController.text.trim(),
      // 'email': emailController.text.trim(),
      'address': addressController.text.trim(),
      'phone_number': phoneController.text.trim(),
    };

    setState(() => _loading = true);

    try {
      if (widget.onSave != null) {
        await widget.onSave!(updated);
      }
      Navigator.pop(context, updated);
    } catch (e) {
      // handle save error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Color(0xFFFCFAF3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildField('User name', nameController,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter name' : null),
                // _buildField('Email', emailController,
                //     keyboardType: TextInputType.emailAddress, validator: (v) {
                //   if (v == null || v.trim().isEmpty) return 'Enter email';
                //   final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                //   if (!emailRegex.hasMatch(v.trim()))
                //     return 'Enter valid email';
                //   return null;
                // }),
                _buildField('Address', addressController,
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter address' : null),
                _buildField('Phone Number', phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter phone number'
                        : null),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _loading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.white), // ensure text white
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    // Put the shadow and rounded corners on the Container
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontFamily: 'Quicksand',
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent, // container already has white bg
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_nexus/helpers/adminPageSupabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_nexus/appColors.dart';
import 'package:intl/intl.dart';

class discountAdd extends StatefulWidget {
  const discountAdd({super.key});

  @override
  State<discountAdd> createState() => _discountAddState();
}

class _discountAddState extends State<discountAdd> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _minimumSpendController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _discountValueController =
      TextEditingController();
  final supabaseHelper = AdminSupabaseHelper();

  final TextEditingController _usageLimitController = TextEditingController();
  String _status = "Active"; // default
  String? _selectedDiscountType;
  bool _submitLoading = false;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm');

  DateTime? _startDate;
  DateTime? _endDate;

  // Availability
  bool _isAvailable = true;

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    // Pick the date first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now),
      firstDate: isStart
          ? DateTime(now.year, now.month, now.day)
          : (_startDate ?? DateTime(now.year, now.month, now.day)),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return; // user cancelled

    // Then pick the time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (pickedTime == null) return; // user cancelled

    // Combine date + time
    final DateTime fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Convert to UTC (for timestampz)
    final DateTime utcDateTime = fullDateTime.toUtc();

    setState(() {
      if (isStart) {
        _startDate = utcDateTime;

        // optional: reset endDate if it's before startDate
        if (_endDate != null && _endDate!.isBefore(utcDateTime)) {
          _endDate = null;
        }
      } else {
        _endDate = utcDateTime;
      }
    });

    // Debug print
    print(
        '${isStart ? 'Start' : 'End'} date selected: $utcDateTime'); // ISO format: 2025-10-14T13:25:00Z
  }

  Future<void> _finalSubmit() async {
    try {
      print(
          '--------------------------------------------------------------------------------------------');

      print(_startDate);
      print(_endDate);

      final response = await supabaseHelper.insert('Discounts', {
        'type': _selectedDiscountType,
        'minimumSpend': int.parse(_minimumSpendController.text),
        'value': int.parse(_discountValueController.text),
        'desc': _descController.text,
        'usage_limit': _usageLimitController.text.isNotEmpty
            ? int.parse(_usageLimitController.text)
            : null,
        'isActive': _isAvailable,
        'start_date': _startDate?.toUtc().toIso8601String(),
        'expiry_date': _endDate?.toUtc().toIso8601String(),
        'code': _codeController.text,
      });

      print(response);
      print(response['data']['id']);

      if (response['status'] != 'success') {
        setState(() {
          _submitLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Eror happened...."),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _submitLoading = false);
          return;
        });
      } else {
        _confirmSuccess();
      }
    } catch (e) {
      print("Error submitting final submit: $e");
      setState(() => _submitLoading = false);
    }
  }

  void _confirmSuccess() {
    setState(() {
      _submitLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Discount added!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/discounts', (r) => false);
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.brown, // Label text color
        fontFamily: 'Quicksand', // Your global font
        fontWeight: FontWeight.w500, // optional
      ),
      hintText: 'Enter $label',
      hintStyle: const TextStyle(
        color: AppColors.input, // Placeholder color
        fontFamily: 'Quicksand', // Use Quicksand here too
      ),
      prefixIcon: Icon(icon, color: Colors.brown),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown, width: 2),
      ),
    );
  }

  InputDecoration dropdownStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.brown,
        fontFamily: 'Quicksand',
        fontWeight: FontWeight.w500,
      ),
      hintText: 'Select $label',
      hintStyle: const TextStyle(
        color: AppColors.input, // same placeholder color
        fontFamily: 'Quicksand',
      ),
      prefixIcon: Icon(icon, color: Colors.brown),
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Product",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount Code
              const Text("Discount Code",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _codeController,
                decoration: inputStyle("", Icons.sell_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter discount code" : null,
              ),
              const SizedBox(height: 16),

              // Description
              const Text("Description",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: inputStyle("", Icons.short_text_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 16),

              // Discount Type Dropdown
              const Text("Discount Type",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                decoration: dropdownStyle("", Icons.local_offer),
                value: _selectedDiscountType,
                items: const [
                  DropdownMenuItem(
                    value: "percentage",
                    child: Text("Percentage (example: 10% off)"),
                  ),
                  DropdownMenuItem(
                    value: "fixed",
                    child: Text("Fixed amount (example: \$50 off)"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDiscountType = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a discount type" : null,
              ),
              const SizedBox(height: 16),

              // Discount Value
              const Text("Discount Value",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _discountValueController,
                keyboardType: TextInputType.number,
                decoration: inputStyle(
                    "",
                    _selectedDiscountType == 'percentage'
                        ? Icons.percent
                        : Icons.money_off_csred_outlined),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Enter discount value";
                  }

                  final value = double.tryParse(val);
                  if (value == null) {
                    return "Enter a valid number";
                  }

                  if (_selectedDiscountType == 'percentage' && value > 100) {
                    return "Rate discounts can't be over 100%";
                  }

                  if (value <= 0) {
                    return "Discount must be greater than zero";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Minimum Spend Value
              const Text("Minimum Spend",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _minimumSpendController,
                keyboardType: TextInputType.number,
                decoration: inputStyle("", Icons.price_check_outlined),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Enter discount value";
                  }

                  final value = double.tryParse(val);
                  if (value == null) {
                    return "Enter a valid number";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Usage Limit
              const Text("Usage Limit (Per Customer)",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _usageLimitController,
                keyboardType: TextInputType.number,
                decoration: inputStyle("", Icons.person_pin_circle_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter usage limit" : null,
              ),
              const SizedBox(height: 16),

              // Validity Period
              const Text("Validity Period",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary)),
              const SizedBox(height: 4),

              Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickDate(context, true),
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Start Date & Time",
                          suffixIcon: const Icon(Icons.calendar_today,
                              color: Colors.brown),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _startDate == null
                              ? ""
                              : _formatter.format(_startDate!.toLocal()),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? "Select start date"
                            : null,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                    child: Text("To"),
                  ),
                  GestureDetector(
                    onTap: () => _pickDate(context, false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "End Date & Time",
                          suffixIcon: const Icon(Icons.calendar_today,
                              color: Colors.brown),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _endDate == null
                              ? ""
                              : _formatter.format(_endDate!.toLocal()),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? "Select end date"
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Availability Switch
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Available",
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (val) {
                        setState(() {
                          _isAvailable = val;
                        });
                      },
                      activeColor: Colors.white, // thumb color when ON
                      activeTrackColor:
                          AppColors.primary, // track color when ON
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        backgroundColor: Colors.white, // <-- white background
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // 15px radius
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Finalize Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // 15px radius
                        ),
                      ),
                      onPressed: _submitLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _submitLoading = true;
                                });
                                _finalSubmit();
                              }
                            },
                      child: _submitLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Finalize Discount",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

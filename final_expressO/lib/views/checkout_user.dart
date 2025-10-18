import 'package:firebase_nexus/helpers/local_database_helper.dart';
import 'package:firebase_nexus/helpers/userPageSupabaseHelper.dart';
import 'package:firebase_nexus/main.dart';
import 'package:firebase_nexus/models/supabaseProduct.dart';
import 'package:firebase_nexus/providers/navigation_provider.dart';
import 'package:firebase_nexus/providers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  final List<SupabaseProduct> checkOutItems;
  const CheckoutPage({super.key, required this.checkOutItems});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool loading = false;
  bool goToOrders = false;
  bool isOnlinePayment = false;
  bool showDiscountField = false;
  bool discountApplied = false;
  int? couponID = null;
  final TextEditingController discountController = TextEditingController();
  UserSupabaseHelper userSupabaseHelper = UserSupabaseHelper();
  SQLFliteDatabaseHelper localDBhelper = SQLFliteDatabaseHelper();

  final double shippingFee = 0.0;
  // final double shippingFee = 50.0;
  double voucherDiscount = 0.0;

  double get subtotal => widget.checkOutItems
      .fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get totalPayment => (subtotal + shippingFee) - voucherDiscount;

  @override
  void initState() {
    print(widget.checkOutItems.map((item) => item.toMap()).toList());
    // TODO: implement initState
    super.initState();
  }

  void _checkCoupon(String code) async {
    final response = await userSupabaseHelper.checkCoupon(code);
    String message;
    bool success = false;

    if (response?['success'] == true && response?['data'] != null) {
      final coupon = response?['data'];
      final now = DateTime.now();
      final startDate = DateTime.parse(coupon['start_date']);
      final expiryDate = DateTime.parse(coupon['expiry_date']);

      print(coupon);

      if (coupon['isActive'] != true) {
        message = "This discount is no longer active.";
      } else if (now.isBefore(startDate)) {
        message = "This coupon isn't active yet.";
      } else if (now.isAfter(expiryDate)) {
        message = "This coupon has expired.";
      } else if (subtotal < (coupon['minimumSpend'] ?? 0)) {
        message =
            "Minimum spend of ₱${(coupon['minimumSpend'] ?? 0).toStringAsFixed(2)} required.";
      } else {
        // ✅ Valid coupon

        double discount = 0;
        if (coupon['type'] == 'percentage') {
          final rate = (coupon['value'] ?? 0).toDouble();
          discount = subtotal * (rate / 100);
        } else if (coupon['type'] == 'fixed') {
          discount = (coupon['value'] ?? 0).toDouble();
        }

        // Prevent negative total
        final newTotal = (subtotal + shippingFee) - discount;
        if (newTotal < 0) discount = subtotal + shippingFee;

        setState(() {
          couponID = coupon['id'];
          voucherDiscount = discount;
          discountApplied = true;
        });

        message = "Discount applied successfully!";
        success = true;
      }
    } else {
      message = "Invalid discount code.";
    }

    // ✅ UI feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _insertOrder(Map<String, dynamic> orderData) async {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    print(orderData['items']);
    final response = await userSupabaseHelper.insertOrder(orderData);
    String message;
    bool success = response['success'] == true;

    print(response['success'] == true);
    print(response['data'] != null);
    print(widget.checkOutItems);

    if (response['success'] == true && response['data'] != null) {
      message = "Order inserted successfully!";

      for (final item in widget.checkOutItems) {
        print('-------------------------------------');
        print(item);
        print('-------------------------------------');
        await localDBhelper.deleteRow('cart', item.id);
      }
      navProvider.setIndex(2);
      setState(() {
        goToOrders = true;
      });
    } else {
      message = "There was a problem in our end, please try again later.";
    }

    // ✅ UI feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF38241D);
    const background = Color(0xFFFFF9F2);

    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isLoaded || userProvider.user == null) {
      userProvider.loadUser(context);
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (goToOrders) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }

    final user = userProvider.user;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2c1d16),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Check Out",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: "Address",
              icon: Icons.location_on_outlined,
              child: Text(
                user?['address'],
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: "Items",
              icon: Icons.coffee_outlined,
              child: Column(
                children: widget.checkOutItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₱${item.price.toStringAsFixed(2)}  x${item.quantity}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${item.name}   ",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              Text(
                                "${item.category} • ${item.variation}",
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Product Image
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: item.img != null
                              ? NetworkImage(item.img!)
                              : const AssetImage(
                                      'assets/images/placeholder.png')
                                  as ImageProvider,
                          backgroundColor: Colors.transparent,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _buildDiscountSection(brown),
            const SizedBox(height: 12),
            _buildSection(
              title: "Payment Method",
              icon: Icons.credit_card_outlined,
              child: Column(
                children: [
                  RadioListTile<bool>(
                    title: const Text("Pay at the counter"),
                    secondary: const Icon(Icons.store),
                    activeColor: brown,
                    value: false,
                    groupValue: isOnlinePayment,
                    onChanged: (val) => setState(() => isOnlinePayment = val!),
                  ),
                  RadioListTile<bool>(
                    title: const Text("Online Payment"),
                    secondary: const Icon(Icons.payment_outlined),
                    activeColor: brown,
                    value: true,
                    groupValue: isOnlinePayment,
                    onChanged: (val) => setState(() => isOnlinePayment = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: "Payment Details",
              icon: Icons.receipt_long_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shippingFee > 0)
                    _buildPaymentRow("Shipping", shippingFee),
                  _buildPaymentRow("Subtotal", subtotal),
                  if (voucherDiscount > 0)
                    _buildPaymentRow("Voucher Applied", -voucherDiscount,
                        isDiscount: true),
                  const Divider(),
                  _buildPaymentRow("Total Payment", totalPayment, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildBottomSummary(
                brown,
                user,
                widget.checkOutItems,
                isOnlinePayment ? 'Gcash' : 'Cash on Delivery',
                couponID,
                loading),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    const brown = Color(0xFF38241D);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: brown, size: 18),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    color: brown, fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildDiscountSection(Color brown) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showDiscountField = !showDiscountField;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.local_offer_outlined, color: brown, size: 18),
                  const SizedBox(width: 6),
                  Text("Add Discount Code",
                      style: TextStyle(
                          color: brown,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ]),
                Icon(
                  showDiscountField
                      ? Icons.expand_less
                      : Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          if (showDiscountField) ...[
            const SizedBox(height: 10),
            TextField(
              controller: discountController,
              decoration: InputDecoration(
                hintText: "Enter your discount code",
                hintStyle: const TextStyle(color: Colors.black38),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: brown.withOpacity(0.3), width: 1),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe37c19),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _checkCoupon(discountController.text);

                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                //   backgroundColor: discountApplied ? Colors.green : Colors.red,
                //   content: Text(discountApplied
                //       ? "Discount Applied Successfully!"
                //       : "Invalid Discount Code"),
                //   duration: const Duration(seconds: 2),
                // ));
              },
              child: const Text("Apply",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, double value,
      {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
                  color: Colors.black87)),
          Text(
            "₱${value.toStringAsFixed(2)}",
            style: TextStyle(
              color: isDiscount ? Colors.red : Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(
      Color brown,
      Map<String, dynamic>? user,
      List<SupabaseProduct> items,
      String payment_method,
      int? discountId,
      bool loading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Total: ₱${totalPayment.toStringAsFixed(2)}",
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ElevatedButton(
            onPressed: loading
                ? null
                : () {
                    setState(() {
                      loading = true;
                    });
                    _insertOrder({
                      'user_id': user?['id'],
                      'payment_method': payment_method,
                      'items': items.map((item) => item.toMap()).toList(),
                      'discount_id': couponID,
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe37c19),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              "Check out",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}

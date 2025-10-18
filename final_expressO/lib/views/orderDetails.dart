import 'package:flutter/material.dart';

class OrderDetails extends StatelessWidget {
  const OrderDetails({super.key});

  void _showPopup(BuildContext context, int type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFCFAF3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: SizedBox(
          width: 300,
          height: 300, // increased height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // center contents
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (type == 1) ...[
                // ✅ Success Popup
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Successful!",
                  style: TextStyle(
                    color: Color(0xFF603B17),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Thank you! Your order was placed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9C7E60),
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9C7E60),
                    fontSize: 14,
                  ),
                ),
              ] else if (type == 2) ...[
                // 👜 Cancelled Popup
                const Icon(Icons.shopping_bag,
                    color: Color(0xFFFFA200), size: 60),
                const SizedBox(height: 16),
                const Text(
                  "Order Cancelled",
                  style: TextStyle(
                    color: Color(0xFF603B17),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We're sorry to see you cancel, but we",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9C7E60),
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "hope to serve you again soon.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9C7E60),
                    fontSize: 14,
                  ),
                ),
              ] else if (type == 3) ...[
                // 👏 Thanks Popup
                const Text("👏", style: TextStyle(fontSize: 50)),
                const SizedBox(height: 16),
                const Text(
                  "Thanks for placing your order!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF603B17),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Thank you for placing your order",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9C7E60),
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "#999012",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF9C7E60),
                  ),
                ),
                const Text(
                  "You will receive a notification once your order has been completed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9C7E60),
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Common Button
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE27D19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Go back to Homepage",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFAED),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                Image.asset(
                  'assets/images/coffee_order_pic.png',
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                // "No records yet"
                const Text(
                  "No records yet",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Color(0xFF603B17),
                  ),
                ),
                const SizedBox(height: 25),

                // "This space looks empty..."
                const Text(
                  "This space looks empty...let's fill it with",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    color: Color(0xFF9C7E60),
                  ),
                ),
                const SizedBox(height: 4),

                // "something delicious"
                const Text(
                  "something delicious",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w200,
                    color: Color(0xFF9C7E60),
                  ),
                ),
                const SizedBox(height: 32),

                // Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE27D19),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Go back to Homepage",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3 Circle Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(context, 1, Colors.brown),
                    const SizedBox(width: 16),
                    _circleButton(context, 2, Colors.orange),
                    const SizedBox(width: 16),
                    _circleButton(context, 3, Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(BuildContext context, int type, Color color) {
    return GestureDetector(
      onTap: () => _showPopup(context, type),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminProfilePage(),
  ));
}

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool isOpen = true; // Button state

  @override
  Widget build(BuildContext context) {
    const Color brownColor = Color(0xFF38241D); 
    const Color lightBackground = Color(0xFFF8F3E9); 

    const String profileImageUrl =
        'https://png.pngtree.com/png-clipart/20220119/ourmid/pngtree-coffee-icon-icon-element-png-image_4237513.png'; 

    return Scaffold(
      backgroundColor: lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: brownColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Profile Image from URL
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: const NetworkImage(profileImageUrl),
                    onBackgroundImageError: (_, __) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Express-O',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'admin123@gmail.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Responsive button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isOpen = !isOpen;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOpen ? Colors.green : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      isOpen ? 'Open' : 'Close',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mobile Number Card
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: InfoCard(
                icon: Icons.phone_android,
                title: 'Mobile Number',
                content: '09123456789',
              ),
            ),

            const SizedBox(height: 10),

            // Address Card
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: InfoCard(
                icon: Icons.location_on,
                title: 'Address',
                content:
                    'Blk 1 Lt 2 Ph 2 Maple Street Diamond Ville\nSalawag Dasmarinas Cavite',
              ),
            ),

            const SizedBox(height: 10),

            // About us Card
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: InfoCard(
                icon: Icons.info_outline,
                title: 'About us',
                content:
                    'An online café and food delivery service offering freshly brewed coffee, delicious meals, and convenient doorstep delivery.',
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Reusable info card widget
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38241D).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF38241D)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF38241D),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

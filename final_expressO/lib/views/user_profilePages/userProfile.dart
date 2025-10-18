import 'package:firebase_nexus/providers/userProvider.dart';
import 'package:firebase_nexus/widgets/editprofile_modal.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_nexus/views/user_profilePages/user_recentActivities.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isProfileExpanded = true;
  bool _isAboutExpanded = true;
  // bool _isActivitiesExpanded = true;

  Future<void> _logout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Clear user in provider + shared preferences
    await userProvider.clearUser(context);

    // Navigate to login (replace with your actual login route)
    if (mounted) {
      Navigator.pushNamed(context, '/tioLogin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isLoaded || userProvider.user == null) {
      userProvider.loadUser(context);
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Brown Top Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                color: Color.fromRGBO(56, 36, 29, 1), // Brown background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Row with Icons and Profile Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Arrow Icon
                      IconButton(
                        onPressed: () {
                          // Handle back navigation
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      // Profile Title in white
                      Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFFFFEF9), // White text on brown
                        ),
                      ),

                      // Settings/Menu Icon
                      IconButton(
                        onPressed: () {
                          // Handle settings/menu button press
                          _showSettingsMenu(context, user);
                        },
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // Avatar with white border
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(
                          226, 125, 25, 1), // Orange background for avatar
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromRGBO(226, 125, 25, 1),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getFirstTwoInitials(user?['username']),
                        style: TextStyle(
                          color: Color(0xFFFFFFFF), // White text
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Name in white
                  Text(
                    user?['username'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // White text
                    ),
                  ),
                  SizedBox(height: 12),

                  // Email in light color
                  Text(
                    user?['email'],
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(158, 255, 255, 255)
                          .withOpacity(0.8), // Semi-transparent white
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20), // Space between brown section and content

            // Profile Details Section
            _buildProfileSection(
              title: "Profile Details",
              isExpanded: _isProfileExpanded,
              onTap: () {
                setState(() {
                  _isProfileExpanded = !_isProfileExpanded;
                });
              },
              content: _buildProfileDetails(
                address: user?['address'],
                phonenum: user?['phone_number'],
              ),
            ),

            // // About Us Section
            // _buildProfileSection(
            //   title: "About Us",
            //   isExpanded: _isAboutExpanded,
            //   onTap: () {
            //     setState(() {
            //       _isAboutExpanded = !_isAboutExpanded;
            //     });
            //   },
            //   content: _buildAboutUs(),
            // ),

            // Recent Activities button
            _buildRecentActivitiesButton(),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context, Map<String, dynamic>? user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => EditProfileModal(
                      user: {
                        'name': user?['username'],
                        'address': user?['address'],
                        'phone_number': user?['phone_number'],
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  Navigator.pop(context);
                  await _logout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Column(
      children: [
        // Section Header with subtle background
        Container(
          color: Colors.grey[50],
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF603B17),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Color(0xFF603B17),
            ),
            onTap: onTap,
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),

        // Content
        if (isExpanded) content,

        // Divider between sections
        Container(height: 8, color: Colors.white),
      ],
    );
  }

  Widget _buildProfileDetails({
    required String address,
    required String phonenum,
  }) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFF603B17),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Address",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Mobile Number Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.phone,
                color: Color(0xFF603B17),
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      phonenum,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildAboutUs() {
  //   return Container(
  //     color: Colors.white,
  //     padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(
  //           Icons.info_outline,
  //           color: Color(0xFF603B17),
  //           size: 20,
  //         ),
  //         SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 "About Us",
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               Text(
  //                 "Add your about us content here...",
  //                 style: TextStyle(
  //                   fontSize: 15,
  //                   color: Colors.grey[700],
  //                   height: 1.5,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRecentActivitiesButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserRecentActivities(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF603B17),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('View Recent Activities'),
        ),
      ),
    );
  }
}

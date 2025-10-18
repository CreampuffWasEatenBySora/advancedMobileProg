import 'dart:math';
import 'package:flutter/material.dart';

/// Modular status badge placed outside NotifPage so it can be reused.
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  // returns background color and text color for a given status
  Map<String, Color> _getColors(String status) {
    switch (status) {
      case 'For Pickup':
        return {
          'bg': const Color(0xFFFACBAE),
          'text': const Color(0xFFC95B17),
        };
      case 'Pending':
        return {
          'bg': const Color(0xFFECF0CB),
          'text': const Color(0xFF95A41E),
        };
      case 'Completed':
        return {
          'bg': const Color(0xFFCBF0D8),
          'text': const Color(0xFF1EA44B),
        };
      case 'Processing':
        return {
          'bg': const Color(0xFFCBDBF0),
          'text': const Color(0xFF1E58A4),
        };
      case 'Cancelled':
        return {
          'bg': const Color(0xFFF0D0CB),
          'text': const Color(0xFFA42E1E),
        };
      default:
        return {
          'bg': const Color(0xFFEDEDED),
          'text': const Color(0xFF333333),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w600,
          color: colors['text'],
          fontSize: 12,
        ),
      ),
    );
  }
}

class UserRecentActivities extends StatefulWidget {
  const UserRecentActivities({super.key});

  @override
  State<UserRecentActivities> createState() => _UserRecentActivitiesState();
}

class _UserRecentActivitiesState extends State<UserRecentActivities> {
  final _rand = Random();
  final sampleStatuses = [
    'For Pickup',
    'Pending',
    'Completed',
    'Processing',
    'Cancelled'
  ];

  // Human-readable “time ago” badge for each mocked timestamp.
  String _timeAgoText(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Builds a single transaction tile with icon, copy, and status badge.
  Widget buildCard({
    required DateTime createdAt,
    required String status,
  }) {
    final timeText = _timeAgoText(createdAt);
    const double cardHeight = 140.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: cardHeight,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEF9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.36),
                blurRadius: 2,
                spreadRadius: 0,
                offset: const Offset(2, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // icon circle...
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F2E2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_cafe,
                    size: 22,
                    color: Color(0xFF603B17),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Color(0xFFC8A888),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Review your order",
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF603B17),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Your order #999897 was completed.",
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 13,
                        color: Color(0xFFC8A888),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              StatusBadge(status: status),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF38241D),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 68, // slightly taller for breathing room
        elevation: 0,

        title: const Text(
          "Recent Activities",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ListView(
            children: [
              // Vertical spacing before the feed.
              const SizedBox(height: 30),
              // Randomized activity list (acts as placeholder data).
              Column(
                children: List.generate(5, (index) {
                  final status =
                      sampleStatuses[_rand.nextInt(sampleStatuses.length)];
                  final minutesAgo = _rand.nextInt(120); // 0..119 minutes ago
                  final createdAt =
                      DateTime.now().subtract(Duration(minutes: minutesAgo));
                  return buildCard(createdAt: createdAt, status: status);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

/// Small reusable chip showing an order status with contextual colors.
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  // Maps a status string to the badge background and text colors.
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

/// Animated border wrapper used to highlight high-priority cards.
class PulsingBorder extends StatefulWidget {
  final Widget child;
  final double minWidth;
  final double maxWidth;
  final Color color;
  final BorderRadius borderRadius;
  final Duration duration;

  const PulsingBorder({
    super.key,
    required this.child,
    this.minWidth = 1.0,
    this.maxWidth = 2.0,
    this.color = const Color(0xFFB3B3B3),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  _PulsingBorderState createState() => _PulsingBorderState();
}

class _PulsingBorderState extends State<PulsingBorder>
    with SingleTickerProviderStateMixin {
  // Animation controller that drives the pulsating stroke.
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    // Configure and start the looping thickness animation.
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: widget.minWidth, end: widget.maxWidth).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    // Release animation resources when the widget goes away.
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Overlay the animated stroke without affecting the child's layout.
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // The child defines the layout (fixed size if you wrap it with SizedBox)
            child!,
            // Overlay painter that draws the border without affecting layout.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BorderPainter(
                    strokeWidth: _anim.value,
                    color: widget.color,
                    borderRadius: widget.borderRadius,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Custom painter that renders the rounded stroke used by [PulsingBorder].
class _BorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final BorderRadius borderRadius;

  _BorderPainter({
    required this.strokeWidth,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;
    // Draw stroke centered on the edge; strokeWidth won't push layout.
    canvas.drawRRect(rrect.deflate(strokeWidth / 2), paint);
  }

  @override
  bool shouldRepaint(covariant _BorderPainter old) {
    // Repaint whenever the stroke appearance changes.
    return old.strokeWidth != strokeWidth || old.color != color;
  }
}

/// Admin notifications feed showing high-priority alerts on top.
class AdminNotifPage extends StatefulWidget {
  const AdminNotifPage({super.key});

  @override
  State<AdminNotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<AdminNotifPage> {
  final _rand = Random();
  // Pool of sample statuses used to mock notification data.
  final sampleStatuses = [
    'For Pickup',
    'Pending',
    'Completed',
    'Processing',
    'Cancelled'
  ];

  // Formats a timestamp into a simple “time ago” label.
  String _timeAgoText(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Builds a single notification card; applies a pulsing border when flagged.
  Widget buildCard({
    required DateTime createdAt,
    required String status,
    bool isHighPriority = false,
  }) {
    final timeText = _timeAgoText(createdAt);
    const double cardHeight = 140.0;

    final cardBody = SizedBox(
      height: cardHeight,
      child: Container(
        // no outer margin here
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
    );

    // Keep the same outer spacing for both types
    if (!isHighPriority) {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 12), child: cardBody);
    }

    // For high priority: wrap with PulsingBorder (overlay) and same outer spacing.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: PulsingBorder(
        minWidth: 1.0,
        maxWidth: 2.5,
        duration: const Duration(milliseconds: 900),
        color: const Color(0xFFE27D19),
        borderRadius: BorderRadius.circular(12),
        child: cardBody,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold containing the high priority section and regular notifications.
    return Scaffold(
      backgroundColor: const Color(0XFFFFFAED),
      appBar: AppBar(
        backgroundColor: const Color(0xFF38241D),
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ListView(
            children: [
              const SizedBox(height: 30),
              const Text(
                "High Priority",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // High Priority vertical list (3 items)
              Column(
                children: List.generate(3, (index) {
                  final status =
                      sampleStatuses[_rand.nextInt(sampleStatuses.length)];
                  final hoursAgo = _rand.nextInt(12); // 0..11 hours ago
                  final createdAt =
                      DateTime.now().subtract(Duration(hours: hoursAgo));
                  return buildCard(
                    createdAt: createdAt,
                    status: status,
                    isHighPriority: true, // enable pulse here
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Dashed divider
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: DashedLinePainter(),
              ),

              const SizedBox(height: 16),

              // Other Notifications title
              const Text(
                "Other Notifications",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Render the rest of the feed without the pulsing accent.
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

/// Simple dashed separator that can be dropped between sections
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

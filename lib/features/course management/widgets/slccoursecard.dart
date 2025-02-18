import 'package:flutter/material.dart';

class SLCCourseCard extends StatefulWidget {
  final String title;
  final String name;
  final List<String> notifications; // Now accepts multiple notifications
  final EventCardColor color;
  final VoidCallback? onTap;

  const SLCCourseCard({
    super.key,
    required this.title,
    required this.name,
    required this.notifications,
    this.color = EventCardColor.blue,
    this.onTap,
  });

  @override
  _SLCCourseCardState createState() => _SLCCourseCardState();
}

class _SLCCourseCardState extends State<SLCCourseCard> {
  bool _isTapped = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isTapped = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isTapped = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isTapped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.color.backgroundColor;
    final Color textColor = Colors.white;

    double screenWidth = MediaQuery.sizeOf(context).width;

    final int notificationCount = widget.notifications.length;
    final List<String> displayedNotifications = [];
    int remainingNotificationCount = 0;

    if (notificationCount == 1) {
      displayedNotifications.add(widget.notifications[0]);
    } else if (notificationCount == 2) {
      displayedNotifications.addAll(widget.notifications.take(2));
    } else if (notificationCount > 2) {
      displayedNotifications.add(widget.notifications.first); // Show latest
      remainingNotificationCount = notificationCount - 1; // Remaining count
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(25, 0, 0, 0),
              spreadRadius: 0,
              blurRadius: 5,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                decoration: BoxDecoration(
                  color: _isTapped
                      ? Color.alphaBlend(
                          Color.fromARGB(255, 213, 213, 213).withOpacity(0.3),
                          backgroundColor)
                      : backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                width: double.infinity,
                height: 150,
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -150,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(65, 227, 227, 227),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu_book, color: textColor, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Notifications section
                              SizedBox(
                                width: 110, // Keep a fixed width
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 5, // Space between badges
                                  runSpacing: 4, // Space between rows
                                  children: [
                                    for (String notification
                                        in displayedNotifications)
                                      _buildNotificationBadge(notification),
                                    if (remainingNotificationCount > 0)
                                      _buildNotificationBadge(
                                          "+$remainingNotificationCount more"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Name
                          SizedBox(
                            width: screenWidth * 0.45,
                            height: 45,
                            child: Text(
                              widget.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom arrow button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward,
                            color: widget.color.backgroundColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pinned indicator
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: widget.color.backgroundColor,
                width: 5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: widget.color.backgroundColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

enum EventCardColor { blue, green, purple, black, yellow }

extension EventCardColorExtension on EventCardColor {
  Color get backgroundColor {
    switch (this) {
      case EventCardColor.blue:
        return const Color(0xFF0013A2);
      case EventCardColor.green:
        return const Color(0xFF469D84);
      case EventCardColor.purple:
        return const Color(0xFF7300C5);
      case EventCardColor.black:
        return Colors.black;
      case EventCardColor.yellow:
        return const Color.fromARGB(255, 222, 171, 6);
    }
  }

  Color get textColor {
    return Colors.white;
  }
}

import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:intl/intl.dart';

class SLCCalendarEventCard extends StatefulWidget {
  final String title;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final CourseColor color;
  final VoidCallback? onTap;

  const SLCCalendarEventCard({
    Key? key,
    required this.title,
    this.location,
    required this.startTime,
    required this.endTime,
    this.color = CourseColor.navyBlue,
    this.onTap,
  }) : super(key: key);

  @override
  State<SLCCalendarEventCard> createState() => _SLCCalendarEventCardState();
}

class _SLCCalendarEventCardState extends State<SLCCalendarEventCard> {
  bool _isTapped = false;

  String formatDateTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = SLCColors.getCourseColor(widget.color);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: _isTapped
              ? Color.alphaBlend(Colors.grey.withOpacity(0.3), backgroundColor)
              : backgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background circle decoration (similar to SLCEventCard)
            Positioned(
              right: -30,
              top: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.location != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              widget.location!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatDateTime(widget.startTime),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatDateTime(widget.endTime),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

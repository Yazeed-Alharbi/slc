import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/common/styles/colors.dart'; // Import SLCColors

class SLCEventCard extends StatefulWidget {
  final String title;
  final String? location;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final CourseColor color; // Use CourseColor instead of EventCardColor
  final String? pinnedText;
  final VoidCallback? onTap;

  const SLCEventCard({
    super.key,
    required this.title,
    this.location,
    required this.startTime,
    this.endTime,
    this.pinnedText,
    this.color = CourseColor.navyBlue, // Default color from CourseColor
    this.onTap,
  });

  @override
  _SLCEventCardState createState() => _SLCEventCardState();
}

class _SLCEventCardState extends State<SLCEventCard> {
  bool _isTapped = false;

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

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
    final bool isPinned = widget.pinnedText != null;

    final Color backgroundColor = isPinned
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white)
        : SLCColors.getCourseColor(
            widget.color); // ✅ Get color from CourseColor

    final Color textColor = isPinned
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black)
        : Colors.white; // Keep white text color for consistency

    double _screenWidth = MediaQuery.sizeOf(context).width;

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
                height: 70,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: _screenWidth * 0.25,
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: _screenWidth * 0.2,
                            child: Text(
                              widget.location ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: _screenWidth * 0.25,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatTimeOfDay(widget.startTime),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                widget.endTime != null
                                    ? Text(
                                        formatTimeOfDay(widget.endTime!),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            isPinned
                ? Positioned(
                    top: -10,
                    left: 25,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: SLCColors.getCourseColor(widget.color),
                      ),
                      height: 25,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: Text(
                            widget.pinnedText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

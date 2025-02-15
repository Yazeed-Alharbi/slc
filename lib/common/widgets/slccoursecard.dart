import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SLCCourseCard extends StatefulWidget {
  final String title;
  final String name;
  final String notification1;
  final String notification2;
  final EventCardColor color;
  final String? pinnedText;
  final VoidCallback? onTap;

  const SLCCourseCard({
    super.key,
    required this.title,
    required this.name,
    required this.notification1,
    required this.notification2,
    this.pinnedText,
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
    final bool isPinned = widget.pinnedText != null;

    final Color backgroundColor = isPinned
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white)
        : widget.color.backgroundColor;

    final Color textColor = isPinned
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black)
        : widget.color.textColor;

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
                          Color.fromARGB(255, 213, 213, 213)
                              .withValues(alpha: 0.3),
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
                          horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.menu_book,
                                      color: textColor, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.title,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    width: 110,
                                    height: 60,
                                    child: Column(
                                      children: [
                                        if (widget.notification1.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255), // Notification color
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 9, // Circle size
                                                  height: 9,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors
                                                        .white, // Outer circle color
                                                    border: Border.all(
                                                      color: widget.color
                                                          .backgroundColor, // Border same as background
                                                      width:
                                                          5, // Thickness of the hollow part
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  widget.notification1,
                                                  style: TextStyle(
                                                    color: widget
                                                        .color.backgroundColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        if (widget.notification2.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255), // Notification color
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 9, // Circle size
                                                  height: 9,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors
                                                        .white, // Outer circle color
                                                    border: Border.all(
                                                      color: widget.color
                                                          .backgroundColor, // Border same as background
                                                      width:
                                                          5, // Thickness of the hollow part
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 12,
                                                ),
                                                Text(
                                                  widget.notification2,
                                                  style: TextStyle(
                                                    color: widget
                                                        .color.backgroundColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          ////
                          ///

                          //
                          SizedBox(
                            width: 180,
                            child: Text(
                              widget.name,
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
                    //new
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // White background
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(
                                40), // Adjusted to match the reference
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        width: 150, // Adjust size to match design
                        height: 50,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward,
                            color: widget
                                .color.backgroundColor, // Matches text color
                            size: 24,
                          ),
                        ),
                      ),
                    ),

//shee
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
                        color: const Color(0xFF469D84),
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
        return const Color.fromARGB(255, 0, 0, 0);
      case EventCardColor.yellow:
        return const Color.fromARGB(255, 222, 171, 6);
    }
  }

  Color get textColor {
    return Colors.white;
  }
}

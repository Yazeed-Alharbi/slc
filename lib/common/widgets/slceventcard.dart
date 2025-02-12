import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SLCEventCard extends StatefulWidget {
  final String title;
  final String? location;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final EventCardColor color;
  final String? pinnedText;
  final VoidCallback? onTap;

  const SLCEventCard({
    super.key,
    required this.title,
    this.location,
    required this.startTime,
    required this.endTime,
    this.pinnedText,
    this.color = EventCardColor.blue,
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
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
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
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: _isTapped
                      ? widget.color.backgroundColor.withOpacity(0.7)
                      : widget.color.backgroundColor,
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
                            width: 100,
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                  color: widget.color.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              widget.location ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.color.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                textAlign: TextAlign.end,
                                formatTimeOfDay(
                                    widget.startTime), // Formatted time
                                style: TextStyle(
                                  color: widget.color.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                textAlign: TextAlign.end,
                                formatTimeOfDay(
                                    widget.endTime), // Formatted time
                                style: TextStyle(
                                  color: widget.color.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
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
            ),
            widget.pinnedText != null
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                          child: Text(
                            widget.pinnedText ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}

enum EventCardColor {
  blue,
  green,
  black,
  white,
}

extension EventCardColorExtension on EventCardColor {
  Color get backgroundColor {
    switch (this) {
      case EventCardColor.blue:
        return const Color(0xFF0013A2);
      case EventCardColor.green:
        return const Color(0xFF469D84);
      case EventCardColor.black:
        return Colors.black;
      case EventCardColor.white:
        return Colors.white;
    }
  }

  Color get textColor {
    switch (this) {
      case EventCardColor.white:
        return Colors.black;
      default:
        return Colors.white;
    }
  }
}

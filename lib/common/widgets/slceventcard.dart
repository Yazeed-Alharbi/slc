import 'package:flutter/material.dart';

class SLCEventCard extends StatelessWidget {
  final String title;
  final String location;
  final String startTime;
  final String endTime;
  final EventCardColor color;
  final bool? pinned;

  const SLCEventCard({
    super.key,
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.pinned = false,
    this.color = EventCardColor.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
           BoxShadow(
            color: Color.fromARGB(25, 0, 0, 0),
            spreadRadius: 0,
            blurRadius: 5,
            offset:  Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: color.backgroundColor,
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
                        Text(
                          title,
                          style: TextStyle(
                            color: color.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          location,
                          style: TextStyle(
                            color: color.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              startTime,
                              style: TextStyle(
                                color: color.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              endTime,
                              style: TextStyle(
                                color: color.textColor,
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
          pinned == true
              ? Positioned(
                  top: -10,
                  left: 25,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFF469D84),
                    ),
                    height: 25,
                    width: 70,
                    child: const Center(
                      child: Text(
                        "ICS 253",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ))
              : Container(),
        ],
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

import 'package:flutter/material.dart';

class AnimatedDigit extends StatelessWidget {
  final String digit;
  final TextStyle style;

  const AnimatedDigit({
    Key? key,
    required this.digit,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        digit,
        key: ValueKey<String>(digit),
        style: style,
      ),
    );
  }
}

class AnimatedTimeDisplay extends StatelessWidget {
  final String timeString;
  final TextStyle style;

  const AnimatedTimeDisplay({
    Key? key,
    required this.timeString,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedDigit(digit: timeString[0], style: style),
        AnimatedDigit(digit: timeString[1], style: style),
        Text(':', style: style),
        AnimatedDigit(digit: timeString[3], style: style),
        AnimatedDigit(digit: timeString[4], style: style),
      ],
    );
  }
}

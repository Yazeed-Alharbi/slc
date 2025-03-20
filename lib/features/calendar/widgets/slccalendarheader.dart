import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/common/widgets/slciconbutton.dart';
import 'package:slc/common/styles/colors.dart';

class SLCCalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const SLCCalendarHeader.SLCCalendarHeader({
    Key? key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SLCIconButton(
          border: Border.all(
            color: SLCColors.coolGray,
            width: 0.25,
          ),
          onPressed: onPrevious,
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
          iconColor: SLCColors.coolGray,
          size: 25,
          icon: Icons.arrow_back,
        ),
        Text(
          DateFormat('MMMM yyyy').format(currentMonth),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontSize: 20),
        ),
        SLCIconButton(
          border: Border.all(
            color: SLCColors.coolGray,
            width: 0.25,
          ),
          onPressed: onNext,
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
          iconColor: SLCColors.coolGray,
          size: 25,
          icon: Icons.arrow_forward,
        ),
      ],
    );
  }
}

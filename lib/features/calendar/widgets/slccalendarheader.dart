import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slc/common/widgets/slciconbutton.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui' as ui;

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
    final l10n = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == ui.TextDirection.rtl;

    // Get month name from localized strings
    String getLocalizedMonth(int month) {
      switch (month) {
        case 1:
          return l10n?.january ?? "January";
        case 2:
          return l10n?.february ?? "February";
        case 3:
          return l10n?.march ?? "March";
        case 4:
          return l10n?.april ?? "April";
        case 5:
          return l10n?.may ?? "May";
        case 6:
          return l10n?.june ?? "June";
        case 7:
          return l10n?.july ?? "July";
        case 8:
          return l10n?.august ?? "August";
        case 9:
          return l10n?.september ?? "September";
        case 10:
          return l10n?.october ?? "October";
        case 11:
          return l10n?.november ?? "November";
        case 12:
          return l10n?.december ?? "December";
        default:
          return "";
      }
    }

    final monthText =
        "${getLocalizedMonth(currentMonth.month)} ${currentMonth.year}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Swap previous and next buttons in RTL mode
        isRTL ? _buildNextButton(context) : _buildPreviousButton(context),

        Text(
          monthText,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontSize: 20),
        ),

        isRTL ? _buildPreviousButton(context) : _buildNextButton(context),
      ],
    );
  }

  Widget _buildPreviousButton(BuildContext context) {
    return SLCIconButton(
      border: Border.all(
        color: SLCColors.coolGray,
        width: 0.25,
      ),
      onPressed: onPrevious,
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,  // Changed from MediaQuery to Theme
      iconColor: SLCColors.coolGray,
      size: 25,
      icon: Directionality.of(context) == ui.TextDirection.rtl
          ? Icons.arrow_forward
          : Icons.arrow_back,
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SLCIconButton(
      border: Border.all(
        color: SLCColors.coolGray,
        width: 0.25,
      ),
      onPressed: onNext,
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,  // Changed from MediaQuery to Theme
      iconColor: SLCColors.coolGray,
      size: 25,
      icon: Directionality.of(context) == ui.TextDirection.rtl
          ? Icons.arrow_back
          : Icons.arrow_forward,
    );
  }
}

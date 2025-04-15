import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SLCCalendarTimeSlots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 24, // Full day (24 hours)
      itemBuilder: (context, index) {
        final hour = index; // Start from 12 AM (0)
        String time;
        if (hour == 0) {
          time = '12 AM'; // Keep AM in English
        } else if (hour < 12) {
          time = '$hour AM'; // Keep AM in English
        } else if (hour == 12) {
          time = '12 PM'; // Keep PM in English
        } else {
          time = '${hour - 12} PM'; // Keep PM in English
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 100,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // Time indicator - make sure it's exactly 60px wide
              Container(
                width: 60,
                padding: EdgeInsets.only(top: 12),
                alignment: isRTL ? Alignment.centerLeft : Alignment.centerRight,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Vertical line - keep consistent width and margins
              Container(
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),

              // Event area - this is where events will be positioned
              Expanded(child: Container()),
            ],
          ),
        );
      },
    );
  }
}

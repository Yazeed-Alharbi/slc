import 'package:flutter/material.dart';

class SLCCalendarTimeSlots extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: 24, // Full day (24 hours)
      itemBuilder: (context, index) {
        final hour = index; // Start from 12 AM (0)
        String time;
        if (hour == 0) {
          time = '12 AM';
        } else if (hour < 12) {
          time = '$hour AM';
        } else if (hour == 12) {
          time = '12 PM';
        } else {
          time = '${hour - 12} PM';
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
            children: [
              // Time indicator
              Container(
                width: 60,
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),

              // Vertical line
              Container(
                width: 1,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),

              // Event area (empty)
              Expanded(child: Container()),
            ],
          ),
        );
      },
    );
  }
}

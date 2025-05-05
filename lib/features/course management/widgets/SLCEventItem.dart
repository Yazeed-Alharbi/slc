import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';
import 'package:intl/intl.dart';
import 'package:slc/models/event.dart';

class SLCEventItem extends StatefulWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color? themeColor;

  const SLCEventItem({
    Key? key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    this.themeColor,
  }) : super(key: key);

  @override
  _SLCEventItemState createState() => _SLCEventItemState();
}

class _SLCEventItemState extends State<SLCEventItem> {
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
    // Use provided theme color or default to primary color
    final Color backgroundColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white;
    final Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: ClipRRect(
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
            // Adjust height dynamically based on whether location exists
            height: widget.event.location != null &&
                    widget.event.location!.isNotEmpty
                ? 160
                : 140,
            child: Stack(
              children: [
                // Background decoration
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

                // Content
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event, color: textColor, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.event.title,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Time and location badges in column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Time badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: textColor, // Full opacity
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: backgroundColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      DateFormat('h:mm a')
                                          .format(widget.event.dateTime),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: backgroundColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Add space between badges
                              if (widget.event.location != null &&
                                  widget.event.location!.isNotEmpty)
                                const SizedBox(height: 8),

                              // Location badge - match the time badge styling exactly
                              if (widget.event.location != null &&
                                  widget.event.location!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color:
                                        textColor, // Same as time badge - full opacity
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: backgroundColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.event.location!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: backgroundColor,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      if (widget.event.description.isNotEmpty)
                        SizedBox(
                          width: screenWidth * 0.7,
                          height: 45,
                          child: Text(
                            widget.event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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

                // Bottom corner with actions
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    width: 120,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: textColor),
                          onPressed: widget.onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: widget.onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';

class SLCQuickActionCard extends StatefulWidget {
  final String title;
  final String? chapter;
  final VoidCallback? onTap;

  const SLCQuickActionCard({
    super.key,
    required this.title,
    this.chapter,
    this.onTap,
  });

  @override
  _SLCQuickActionCardState createState() => _SLCQuickActionCardState();
}

class _SLCQuickActionCardState extends State<SLCQuickActionCard> {
  Color _color = Colors.white;
  Color _textColor = Colors.black;
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
    // Get the text direction for proper RTL support
    final textDirection = Directionality.of(context);

    _color = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    _textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        height: 70,
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
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: _isTapped
                  ? Color.alphaBlend(
                      const Color.fromARGB(255, 213, 213, 213)
                          .withValues(alpha: 0.3),
                      _color)
                  : _color,
              borderRadius: BorderRadius.circular(30),
            ),
            width: double.infinity,
            child: Stack(
              children: [
                // Update the positioned decoration circle for RTL support
                Positioned(
                  // Use right for LTR, left for RTL
                  right: textDirection == TextDirection.ltr ? -50 : null,
                  left: textDirection == TextDirection.rtl ? -50 : null,
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
                  child: SizedBox(
                    height: double.infinity,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // First element (title)
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.25,
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Middle element (chapter)
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.2,
                            child: Text(
                              widget.chapter ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Last element (play button) - use alignment.centerEnd instead of centerRight
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.25,
                            child: Align(
                              alignment: AlignmentDirectional
                                  .centerEnd, // This respects text direction
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: SLCColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

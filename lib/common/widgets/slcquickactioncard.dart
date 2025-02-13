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

  @override
  void initState() {
    super.initState();
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
                  child: SizedBox(
                    height: double.infinity,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.25,
                            child: Text(
                              textAlign: TextAlign.start,
                              widget.title,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
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
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.25,
                            child: Align(
                              alignment: Alignment.centerRight,
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

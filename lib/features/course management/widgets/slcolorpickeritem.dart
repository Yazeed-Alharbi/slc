import 'package:flutter/material.dart';

class SLCColorPickerItem extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const SLCColorPickerItem({
    Key? key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _SLCColorPickerItemState createState() => _SLCColorPickerItemState();
}

class _SLCColorPickerItemState extends State<SLCColorPickerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void didUpdateWidget(SLCColorPickerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            Positioned(
              right: -25,
              top: -25,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(65, 227, 227, 227),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

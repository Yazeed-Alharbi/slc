import 'package:flutter/material.dart';

class SLCHeaderTextField extends StatelessWidget {
  final String hintText;
  final double fontSize;
  final FontWeight fontWeight;
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;

  const SLCHeaderTextField({
    Key? key,
    required this.hintText,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.onChanged,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
    );
  }
}

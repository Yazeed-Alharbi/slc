import 'package:flutter/material.dart';
import 'package:slc/common/styles/colors.dart';

class SLCTextField extends StatelessWidget {
  final bool obscureText;
  final String labelText;
  final TextEditingController? controller;
  final Function()? onTapOutside;

  const SLCTextField({
    Key? key,
    this.obscureText = false,
    required this.labelText,
    this.controller,
    this.onTapOutside,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      onTapOutside: (event) {
        if (onTapOutside != null) {
          onTapOutside!();
        } else {
          FocusScope.of(context).unfocus(); // Default behavior
        }
      },
      decoration: InputDecoration(
        label: Text(labelText),
        fillColor: const Color.fromARGB(255, 239, 242, 255),
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color.fromARGB(0, 255, 255, 255)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: SLCColors.primaryColor),
        ),
      ),
    );
  }
}

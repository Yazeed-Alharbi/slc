import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slc/common/styles/colors.dart';

class SLCTextField extends StatelessWidget {
  final bool obscureText;
  final String? labelText;
  final TextEditingController? controller;
  final Function()? onTapOutside;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool? autofocus;
  final int? maxLength;
  final bool? readOnly;
  final bool? enabled;
  final TextAlign? textAlign;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  const SLCTextField({
    Key? key,
    this.obscureText = false,
    this.labelText,
    this.controller,
    this.onTapOutside,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofocus,
    this.maxLength,
    this.readOnly,
    this.enabled,
    this.textAlign,
    this.hintText,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      maxLength: maxLength,
      readOnly: readOnly ?? false,
      enabled: enabled,
      textAlign: textAlign ?? TextAlign.start,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTapOutside: (event) {
        if (onTapOutside != null) {
          onTapOutside!();
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return const TextStyle(color: Colors.red);
          }
          return const TextStyle();
        }),
        errorStyle: TextStyle(
          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
          color: Colors.red,
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color.fromARGB(255, 255, 0, 0)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color.fromARGB(255, 255, 0, 0))),
        label: Text(labelText!),
        hintText: hintText,
        errorMaxLines: 3,
        fillColor: Theme.of(context).colorScheme.surfaceTint,
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
      validator: validator,
    );
  }
}

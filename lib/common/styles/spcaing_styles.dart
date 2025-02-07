import 'package:flutter/material.dart';

class SpacingStyles {
  final BuildContext context;
  late final EdgeInsets defaultPadding;

  SpacingStyles(this.context) {
    defaultPadding = EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).height * 0.03,
        MediaQuery.sizeOf(context).height * 0.1,
        MediaQuery.sizeOf(context).height * 0.03,
        MediaQuery.sizeOf(context).height * 0.1);
  }
}
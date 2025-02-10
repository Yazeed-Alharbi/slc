import 'package:flutter/material.dart';

class SpacingStyles {
  final BuildContext context;
  late final EdgeInsets defaultPadding;
  late final MediaQueryData data;

  SpacingStyles(this.context) {
    data = MediaQuery.of(context);
    defaultPadding = EdgeInsets.fromLTRB(
        data.size.width * 0.05,
        0,
        data.size.width * 0.05,
        0);
  }
}
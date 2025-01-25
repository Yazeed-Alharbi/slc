import 'package:flutter/material.dart';

class SpacingStyles {
  final BuildContext context;
  late final EdgeInsets defaultPadding;

  SpacingStyles(this.context) {
    defaultPadding = EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.height * 0.03,
        MediaQuery.of(context).size.height * 0.1,
        MediaQuery.of(context).size.height * 0.03,
        0);
  }
}

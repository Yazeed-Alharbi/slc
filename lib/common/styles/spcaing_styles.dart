import 'package:flutter/material.dart';

class SpacingStyles {
  final BuildContext context;
  late final EdgeInsets defaultPadding;
  late final MediaQueryData data;

  SpacingStyles(this.context) {
    data = MediaQuery.of(context);
    defaultPadding = EdgeInsets.fromLTRB(
        data.orientation == Orientation.portrait ? data.size.width * 0.05 : data.size.width * 0.1 ,
        data.orientation == Orientation.portrait ? data.size.height * 0.1 : 0 ,
        data.orientation == Orientation.portrait ? data.size.width * 0.05 : data.size.width * 0.1 ,
        0);
  }
}
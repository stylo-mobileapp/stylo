import 'package:flutter/material.dart';

class Constants {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double horizontalSpacing(BuildContext context) =>
      width(context) * 0.025;

  static double fontSize(double fontSize, BuildContext context) {
    return width(context) * fontSize / 375.0;
  }

  static double iconSize(BuildContext context) {
    return width(context) * 0.055;
  }

  static double borderRadius(BuildContext context) {
    return width(context) * 0.02;
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/constants.dart';

class TextSizes {
  static double extraSmall(BuildContext context) =>
      Constants.fontSize(12.0, context);

  static double small(BuildContext context) =>
      Constants.fontSize(14.0, context);

  static double medium(BuildContext context) =>
      Constants.fontSize(16.0, context);

  static double large(BuildContext context) =>
      Constants.fontSize(18.0, context);

  static double extraLarge(BuildContext context) =>
      Constants.fontSize(20.0, context);

  static double title(BuildContext context) =>
      Constants.fontSize(30.0, context);
}

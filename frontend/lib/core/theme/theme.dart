import 'package:flutter/cupertino.dart';
import 'package:frontend/core/theme/palette.dart';

class Theme {
  static CupertinoThemeData themeMode() => const CupertinoThemeData(
    primaryColor: Palette.primaryColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Palette.backgroundColor,
  );
}

import 'package:flutter/cupertino.dart';

class AppTheme {
  static final lightTheme = CupertinoThemeData(brightness: Brightness.light);

  static final darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: CupertinoColors.activeOrange,
    scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
  );
}

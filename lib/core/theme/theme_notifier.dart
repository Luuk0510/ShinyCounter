import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  bool _useOledDark = true;

  ThemeMode get mode => _mode;
  bool get useOledDark => _useOledDark;

  void setMode(ThemeMode mode, {bool? useOledDark}) {
    _mode = mode;
    if (useOledDark != null) {
      _useOledDark = useOledDark;
    }
    notifyListeners();
  }
}

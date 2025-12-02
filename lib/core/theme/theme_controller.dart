import 'package:flutter/material.dart';

class ThemeController extends StatefulWidget {
  const ThemeController({required this.child, super.key});
  final Widget child;

  @override
  State<ThemeController> createState() => ThemeControllerState();

  static ThemeControllerState of(BuildContext context) {
    final state = context.findAncestorStateOfType<ThemeControllerState>();
    if (state == null) {
      throw Exception('ThemeController not found in context');
    }
    return state;
  }
}

class ThemeControllerState extends State<ThemeController> {
  ThemeMode _mode = ThemeMode.system;
  bool _useOledDark = true;

  ThemeMode get mode => _mode;
  bool get useOledDark => _useOledDark;

  void setMode(ThemeMode mode, {bool? useOledDark}) {
    setState(() {
      _mode = mode;
      if (useOledDark != null) {
        _useOledDark = useOledDark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeModeScope(controller: this, child: widget.child);
  }
}

class _ThemeModeScope extends InheritedWidget {
  const _ThemeModeScope({required this.controller, required super.child});

  final ThemeControllerState controller;

  @override
  bool updateShouldNotify(covariant _ThemeModeScope oldWidget) {
    return oldWidget.controller._mode != controller._mode ||
        oldWidget.controller._useOledDark != controller._useOledDark;
  }
}

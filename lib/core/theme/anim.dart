import 'package:flutter/material.dart';

class AppAnim {
  static const faster = Duration(milliseconds: 90);
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const switcher = Duration(milliseconds: 220);
  static const dialogDuration = fast;
  static const sheetDuration = Duration(milliseconds: 200);
  static const longPressDelay = Duration(milliseconds: 500);

  static const easeOut = Curves.easeOut;
  static const easeOutCubic = Curves.easeOutCubic;
  static const dialogCurve = easeOutCubic;
  static const sheetCurve = easeOutCubic;

  static const buttonPressScale = 0.9;
  static const dialogStartScale = 0.8;
  static const listItemPopStartScale = 0.96;
  static const sparkleDuration = Duration(milliseconds: 420);
  static const sparkleStartScale = 0.7;
  static const sparkleEndScale = 1.1;
  static const sparkleRotationTurns = 0.08;
  static const sparkleFadeInFraction = 0.35;
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration staggerDelay = Duration(milliseconds: 60);
  static const Duration shimmerPeriod = Duration(milliseconds: 1500);

  static const Curve springCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve enterCurve = Curves.easeOutCubic;

  static Duration staggerFor(int index) => Duration(milliseconds: 60 * index);

  static Duration staggerCapped(int index) =>
      Duration(milliseconds: 60 * index.clamp(0, 10));
}

class AppHaptics {
  AppHaptics._();

  static void lightTap() => HapticFeedback.lightImpact();

  static void mediumImpact() => HapticFeedback.mediumImpact();

  static void heavyImpact() => HapticFeedback.heavyImpact();

  static void success() => HapticFeedback.mediumImpact();

  static void selectionClick() => HapticFeedback.selectionClick();
}

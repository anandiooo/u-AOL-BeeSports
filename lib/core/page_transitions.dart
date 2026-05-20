import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:beesports/core/animations.dart';

class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: AppAnimations.smoothCurve).animate(animation),
              child: child,
            );
          },
          transitionDuration: AppAnimations.pageTransition,
        );
}

class SlideRightTransitionPage<T> extends CustomTransitionPage<T> {
  SlideRightTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.smoothCurve,
              )),
              child: child,
            );
          },
          transitionDuration: AppAnimations.pageTransition,
        );
}

class SlideUpTransitionPage<T> extends CustomTransitionPage<T> {
  SlideUpTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppAnimations.smoothCurve,
              )),
              child: child,
            );
          },
          transitionDuration: AppAnimations.pageTransition,
        );
}

import 'package:flutter/material.dart';

/// Reusable gradient background used across the auth/splash flows.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.useSafeArea = false,
  });

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.white, Colors.white, Color(0xff0FA6FF)],
          stops: [0.0, 0.3, 1],
        ),
      ),
      child: content,
    );
  }
}







import 'package:flutter/material.dart';

/// خلفية مخصصة لشاشة السبلاش بنفس التدرج المطلوب.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child, this.useSafeArea = false});

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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white,
            Colors.lightBlueAccent,
          ],
          stops: [0.0, 0.3, 1],
        ),
      ),
      child: content,
    );
  }
}


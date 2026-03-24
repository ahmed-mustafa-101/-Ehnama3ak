import 'package:flutter/material.dart';

class AppIconBack extends StatelessWidget {
  const AppIconBack({super.key, required this.top, required this.left});
  final double top;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
    );
  }
}

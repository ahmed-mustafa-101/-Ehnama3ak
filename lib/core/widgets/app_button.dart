import 'package:flutter/material.dart';

/// زر أساسي قابل لإعادة الاستخدام مع نفس تصميم الأزرار الحالية.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconColor = Colors.white,
    this.iconSize = 20,
    this.iconSpacing = 8,
    this.width,
    this.height = 52,
    this.backgroundColor = const Color(0xFF0DA5FE),
    this.radius = 12,
    this.elevation = 6,
    this.textStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color iconColor;
  final double iconSize;
  final double iconSpacing;
  final double? width;
  final double height;
  final Color backgroundColor;
  final double radius;
  final double elevation;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: elevation,
          minimumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: icon == null
            ? Text(label, style: textStyle)
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: iconSize),
                  SizedBox(width: iconSpacing),
                  Text(label, style: textStyle),
                ],
              ),
      ),
    );
  }
}

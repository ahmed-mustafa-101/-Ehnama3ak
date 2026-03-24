import 'package:flutter/material.dart';

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color iconColor;
  final TextStyle? textStyle;

  const ContactItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor = const Color(0xFF0DA5FE),
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(
              text,
              style:
                  textStyle ??
                  const TextStyle(decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;
  final String? trailingText;
  final Widget? trailing;

  const AppTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
    this.trailingText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isLogout ? Colors.red : const Color(0xFF1E88E5);
    final tileColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 26),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout
                ? Colors.red
                : (isDark ? Colors.white : Colors.black87),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? (trailingText != null
            ? Text(
                trailingText!,
                style: const TextStyle(color: Colors.blueGrey),
              )
            : Icon(Icons.chevron_right, color: isDark ? Colors.white70 : null)),
        onTap: onTap,
      ),
    );
  }
}

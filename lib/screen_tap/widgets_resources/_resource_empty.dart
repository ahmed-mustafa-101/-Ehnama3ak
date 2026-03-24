import 'package:flutter/material.dart';

/// Reusable empty-state widget for all three resource tabs.
class ResourceEmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const ResourceEmptyView({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: const Color(0xFF1E88E5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new content.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

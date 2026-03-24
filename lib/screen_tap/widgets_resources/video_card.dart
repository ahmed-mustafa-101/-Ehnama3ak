import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String image;
  final VoidCallback? onTap;

  const VideoCard({
    super.key,
    required this.title,
    required this.duration,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(duration, style: const TextStyle(fontSize: 13)),
        trailing: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Watch'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

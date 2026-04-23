import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.subtitle,
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: SizedBox(
          width: 90,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Read Now', style: TextStyle(fontSize: 12)),
          ),
        ),
      ),
    );
  }
}

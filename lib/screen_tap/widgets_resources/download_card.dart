import 'package:flutter/material.dart';

class DownloadCard extends StatelessWidget {
  final String title;
  final String description;
  final String fileSize;
  final String image;
  final VoidCallback? onDownload;
  final VoidCallback? onRead;

  const DownloadCard({
    super.key,
    required this.title,
    required this.description,
    required this.fileSize,
    required this.image,
    this.onDownload,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    fileSize,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    minimumSize: const Size(90, 34),
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: onRead,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(90, 34),
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                  ),
                  child: const Text(
                    'Read',
                    style: TextStyle(color: Color(0xFF1E88E5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

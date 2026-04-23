import 'package:flutter/material.dart';
import '../models/podcast_model.dart';

class PodcastCard extends StatelessWidget {
  final PodcastModel podcast;
  final VoidCallback onPlay;

  const PodcastCard({super.key, required this.podcast, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFBFE6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.headphones, color: Color(0xff0DA5FE)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  podcast.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  podcast.subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onPlay,
            child: const CircleAvatar(
              backgroundColor: Color(0xff0DA5FE),
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

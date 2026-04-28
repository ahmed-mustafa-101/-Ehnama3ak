import 'package:flutter/material.dart';

ImageProvider buildUserProfileImageProvider(String path) {
  if (path.isEmpty ||
      path.toLowerCase() == 'null' ||
      path.toLowerCase() == 'string') {
    return const AssetImage('assets/images/user_avatar.png');
  }

  String normalizedPath = path.trim().replaceAll('\\', '/');
  if (normalizedPath.startsWith('assets/')) return AssetImage(normalizedPath);
  if (normalizedPath.startsWith('http')) return NetworkImage(normalizedPath);

  const String baseUrl = 'http://e7nama3ak.runasp.net';
  final cleanPath = normalizedPath.startsWith('/')
      ? normalizedPath
      : '/$normalizedPath';
  return NetworkImage('$baseUrl$cleanPath');
}

String formatRelativeTime(DateTime time) {
  final diff = DateTime.now().toUtc().difference(time.toUtc());
  if (diff.inSeconds < 10) return 'Just now';
  if (diff.inSeconds < 60) return '${diff.inSeconds} sec';
  if (diff.inMinutes < 60) return '${diff.inMinutes} mins';
  if (diff.inHours < 24) return '${diff.inHours} hours';
  if (diff.inDays < 7) return '${diff.inDays} days';
  return '${time.day}/${time.month}/${time.year}';
}

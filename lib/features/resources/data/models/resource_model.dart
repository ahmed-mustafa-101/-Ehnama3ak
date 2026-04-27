import 'package:equatable/equatable.dart';

// ─── Resource type enum ───────────────────────────────────────────────────────

enum ResourceType { article, video, pdf, unknown }

extension ResourceTypeX on ResourceType {
  String get label {
    switch (this) {
      case ResourceType.article:
        return 'Article';
      case ResourceType.video:
        return 'Video';
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.unknown:
        return 'Unknown';
    }
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class ResourceModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final ResourceType type;
  final String url;
  final int duration;   // seconds (for videos)
  final int fileSize;   // bytes  (for PDFs)
  final DateTime? createdDate;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.type,
    required this.url,
    required this.duration,
    required this.fileSize,
    this.createdDate,
  });

  // ─── Deserialization ──────────────────────────────────────────────────────

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    dynamic getValue(List<String> keys) {
      for (var k in keys) {
        if (json.containsKey(k)) return json[k];
        final cap = k[0].toUpperCase() + k.substring(1);
        if (json.containsKey(cap)) return json[cap];
      }
      return null;
    }

    String normalizeUrl(String? url) {
      if (url == null || url.trim().isEmpty) return '';
      final u = url.trim();
      if (u.startsWith('http') || u.startsWith('file://') || u.startsWith('/data/') || u.startsWith('C:')) {
        return u;
      }
      if (u.startsWith('/')) {
        return 'http://e7nama3ak.runasp.net$u';
      }
      return 'http://e7nama3ak.runasp.net/$u';
    }

    return ResourceModel(
      id: _parseInt(getValue(['id', 'sessionId'])),
      title: _str(getValue(['title', 'name', 'patientName'])),
      description: _str(getValue(['description', 'summary'])),
      coverImageUrl: _nullable(normalizeUrl(getValue(['coverImageUrl', 'imageUrl', 'image']))),
      type: _parseType(getValue(['type', 'sessionType'])),
      url: normalizeUrl(getValue(['url', 'resourceUrl', 'fileUrl', 'videoUrl', 'pdfUrl', 'audioUrl', 'sessionUrl'])),
      duration: _parseInt(getValue(['duration'])),
      fileSize: _parseInt(getValue(['fileSize', 'size'])),
      createdDate: _parseDate(getValue(['createdDate', 'createdAt', 'date', 'scheduledAt'])),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coverImageUrl': coverImageUrl,
        'type': type.label,
        'url': url,
        'duration': duration,
        'fileSize': fileSize,
        'createdDate': createdDate?.toIso8601String(),
      };

  // ─── Helper getters ───────────────────────────────────────────────────────

  /// "2:30 min" from duration in seconds.
  String get formattedDuration {
    if (duration <= 0) return '';
    final m = duration ~/ 60;
    final s = (duration % 60).toString().padLeft(2, '0');
    return '$m:$s min';
  }

  /// "2.5 MB" from fileSize in bytes.
  String get formattedFileSize {
    if (fileSize <= 0) return '';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _str(dynamic v) => v?.toString().trim() ?? '';

  static String? _nullable(dynamic v) {
    final s = v?.toString().trim() ?? '';
    return s.isEmpty ? null : s;
  }

  static ResourceType _parseType(dynamic v) {
    switch (v?.toString().toLowerCase()) {
      case 'article':
        return ResourceType.article;
      case 'video':
        return ResourceType.video;
      case 'pdf':
      case 'download':
        return ResourceType.pdf;
      default:
        return ResourceType.unknown;
    }
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try { return DateTime.parse(v.toString()); } catch (_) { return null; }
  }

  @override
  List<Object?> get props =>
      [id, title, description, coverImageUrl, type, url, duration, fileSize, createdDate];
}

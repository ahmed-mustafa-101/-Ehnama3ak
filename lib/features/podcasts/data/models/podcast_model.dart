import 'package:equatable/equatable.dart';

class PodcastModel extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String audioUrl;
  final String? imageUrl;
  final String? hostName;
  final int? durationSeconds;
  final DateTime? publishedAt;

  const PodcastModel({
    required this.id,
    required this.title,
    this.description,
    required this.audioUrl,
    this.imageUrl,
    this.hostName,
    this.durationSeconds,
    this.publishedAt,
  });

  /// Parse from JSON — field names are matched flexibly to cover various API shapes.
  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    dynamic getValue(List<String> keys) {
      for (var k in keys) {
        if (json.containsKey(k)) return json[k];
        final cap = k[0].toUpperCase() + k.substring(1);
        if (json.containsKey(cap)) return json[cap];
      }
      return null;
    }

    return PodcastModel(
      id: _parseInt(getValue(['id', 'podcastId']) ?? 0),
      title: _parseString(
        getValue(['title', 'name', 'episodeName', 'patientName']) ?? '',
      ) ?? '',
      description: _parseString(
        getValue(['description', 'subtitle', 'summary']),
      ),
      audioUrl: (getValue(['audioUrl', 'audio_url', 'url', 'fileUrl', 'sessionUrl']) ?? '')
          .toString()
          .trim(),
      imageUrl: _parseString(
        getValue(['imageUrl', 'image_url', 'thumbnailUrl', 'coverImage']),
      ),
      hostName: _parseString(
        getValue(['hostName', 'host', 'author']),
      ),
      durationSeconds: _parseIntOrNull(
        getValue(['durationSeconds', 'duration', 'durationInSeconds']),
      ),
      publishedAt: _parseDate(
        getValue(['publishedAt', 'createdAt', 'date']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'audioUrl': audioUrl,
        'imageUrl': imageUrl,
        'hostName': hostName,
        'durationSeconds': durationSeconds,
        'publishedAt': publishedAt?.toIso8601String(),
      };

  /// Human-readable duration string (e.g. "8:45").
  String get formattedDuration {
    if (durationSeconds == null) return '';
    final m = durationSeconds! ~/ 60;
    final s = (durationSeconds! % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Subtitle shown on the podcast card.
  String get subtitle =>
      description?.isNotEmpty == true ? description! : (hostName ?? '');

  // ─── helpers ────────────────────────────────────────────────────────────────

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _parseIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String? _parseString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        audioUrl,
        imageUrl,
        hostName,
        durationSeconds,
        publishedAt,
      ];
}

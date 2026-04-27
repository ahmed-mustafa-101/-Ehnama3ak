import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ehnama3ak/screens_app/doctor/sessions/models/doctor_session_model.dart';
import 'package:ehnama3ak/core/network/dio_client.dart'; // To get baseUrl

class SessionMediaViewer extends StatefulWidget {
  final DoctorSessionModel session;
  const SessionMediaViewer({super.key, required this.session});

  @override
  State<SessionMediaViewer> createState() => _SessionMediaViewerState();
}

class _SessionMediaViewerState extends State<SessionMediaViewer> {
  // Video Controllers
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // Audio Controller
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _loading = true;
  String? _error;

  String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    // If it's a clear local path on the device, return as is
    if (url.startsWith('/data/') || url.startsWith('/storage/') || url.startsWith('file://') || url.startsWith('C:')) {
      return url;
    }
    // If it's a relative URL from the backend, append the base URL
    if (!url.startsWith('http')) {
      if (url.startsWith('/')) {
        return '${DioClient.baseUrl}$url';
      } else {
        return '${DioClient.baseUrl}/$url';
      }
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  Future<void> _initializeMedia() async {
    final type = widget.session.sessionType?.toLowerCase() ?? '';
    final url = _normalizeUrl(widget.session.sessionUrl ?? '');

    if (url.isEmpty) {
      if (mounted) {
        setState(() {
          _error = "No media URL available";
          _loading = false;
        });
      }
      return;
    }

    try {
      if (type.contains('video')) {
        await _initializeVideo(url);
      } else if (type.contains('audio')) {
        await _initializeAudio(url);
      } else {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error initializing media: $e";
          _loading = false;
        });
      }
    }
  }

  Future<void> _initializeVideo(String url) async {
    try {
      if (url.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        _videoController = VideoPlayerController.file(File(url));
      }

      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      log("Video player error: $e");
      if (mounted) {
        setState(() {
          _error = "Video Player Error: $e";
          _loading = false;
        });
      }
    }
  }

  Future<void> _initializeAudio(String url) async {
    try {
      if (url.startsWith('http')) {
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
      } else {
        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.file(url)));
      }
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      log("Audio player error: $e");
      if (mounted) {
        setState(() {
          _error = "Audio Player Error: $e";
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.session.sessionType?.toLowerCase() ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.session.patientName ?? 'Session Media',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? _buildErrorWidget()
              : _buildMediaContent(type),
    );
  }

  Widget _buildMediaContent(String type) {
    final url = _normalizeUrl(widget.session.sessionUrl ?? '');

    if (type.contains('video')) {
      return Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const Text("Video Error", style: TextStyle(color: Colors.white)),
      );
    } else if (type.contains('audio')) {
      return _buildAudioPlayer();
    } else if (type.contains('pdf')) {
      return _buildPdfViewer(url);
    } else if (type.contains('chat') || type.contains('image')) {
      return _buildImageViewer(url);
    }

    return const Center(
      child: Text("Unsupported Media Type", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildAudioPlayer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.audiotrack, size: 80, color: Color(0xFF0DA5FE)),
          const SizedBox(height: 30),
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;

              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return const CircularProgressIndicator();
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                  onPressed: _audioPlayer.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause_circle_filled, size: 64, color: Colors.white),
                  onPressed: _audioPlayer.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay_circle_filled, size: 64, color: Colors.white),
                  onPressed: () => _audioPlayer.seek(Duration.zero),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          const Text("Audio Session", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(String url) {
    // PDFView only support local files, network PDF requires downloading first
    // For simplicity, we handle local paths directly
    if (!url.startsWith('http')) {
      return PDFView(
        filePath: url,
        autoSpacing: true,
        enableSwipe: true,
        pageSnap: true,
        swipeHorizontal: true,
        onError: (error) {
          setState(() => _error = "PDF Error: $error");
        },
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "Online PDF - View in Browser",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open PDF link')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0DA5FE),
              foregroundColor: Colors.white,
            ),
            child: const Text("Open Link"),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(String url) {
    return Center(
      child: url.startsWith('http')
          ? Image.network(url, fit: BoxFit.contain)
          : Image.file(File(url), fit: BoxFit.contain),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown Error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

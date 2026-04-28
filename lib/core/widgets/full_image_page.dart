import 'dart:io';
import 'package:ehnama3ak/core/utils/image_utils.dart';
import 'package:ehnama3ak/features/feed/data/models/post_model.dart';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FullImagePage extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final PostModel? post; // Added post model

  const FullImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.post,
  });

  @override
  State<FullImagePage> createState() => _FullImagePageState();
}

class _FullImagePageState extends State<FullImagePage> {
  double _dragOffset = 0;
  bool _isDownloading = false;
  final PhotoViewScaleStateController _scaleStateController = PhotoViewScaleStateController();
  final PhotoViewController _photoViewController = PhotoViewController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _photoViewController.outputStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isZoomed = state.scale! > 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleStateController.dispose();
    _photoViewController.dispose();
    super.dispose();
  }

  ImageProvider _getImageProvider(String imagePath) {
    final trimmedPath = imagePath.trim();
    
    if (trimmedPath.startsWith('assets/')) {
      return AssetImage(trimmedPath);
    }

    if (trimmedPath.startsWith('http')) {
      return NetworkImage(trimmedPath);
    }

    final file = File(trimmedPath);
    if (file.existsSync()) {
      return FileImage(file);
    }

    const String baseUrl = 'http://e7nama3ak.runasp.net';
    final fullUrl = trimmedPath.startsWith('/')
        ? '$baseUrl$trimmedPath'
        : '$baseUrl/$trimmedPath';
    
    return NetworkImage(fullUrl);
  }

  Future<void> _downloadImage() async {
    setState(() => _isDownloading = true);
    try {
      if (Platform.isAndroid) {
         await Permission.storage.request();
      }

      final dir = await getTemporaryDirectory(); 
      final fileName = widget.imageUrl.split('/').last;
      final savePath = '${dir.path}/$fileName';

      await Dio().download(widget.imageUrl, savePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded to $savePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - (_dragOffset.abs() / 400)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(opacity),
      body: Stack(
        children: [
          // The image viewer
          GestureDetector(
            onVerticalDragUpdate: _isZoomed ? null : (details) {
              setState(() {
                _dragOffset += details.delta.dy;
              });
            },
            onVerticalDragEnd: _isZoomed ? null : (details) {
              if (_dragOffset.abs() > 150) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _dragOffset = 0;
                });
              }
            },
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Hero(
                tag: widget.heroTag,
                child: PhotoView(
                  controller: _photoViewController,
                  scaleStateController: _scaleStateController,
                  imageProvider: _getImageProvider(widget.imageUrl),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3.0,
                  initialScale: PhotoViewComputedScale.contained,
                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
          ),
          
          // App Bar Overlay
          SafeArea(
            child: AnimatedOpacity(
              opacity: _dragOffset == 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ),
                    if (widget.imageUrl.startsWith('http') || widget.imageUrl.startsWith('/'))
                      GestureDetector(
                        onTap: _isDownloading ? null : _downloadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: _isDownloading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download, color: Colors.white, size: 24),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Post Info Overlay (Bottom)
          if (widget.post != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: (_dragOffset == 0 && !_isZoomed) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: buildUserProfileImageProvider(
                              widget.post!.userProfileImage,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.post!.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.post!.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatItem(Icons.favorite, '${widget.post!.likesCount}', Colors.red),
                          const SizedBox(width: 20),
                          _buildStatItem(Icons.comment, '${widget.post!.commentsCount}', Colors.white),
                          const SizedBox(width: 20),
                          _buildStatItem(Icons.share, '${widget.post!.sharesCount}', Colors.white),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}



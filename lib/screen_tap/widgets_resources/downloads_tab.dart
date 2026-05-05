import 'package:flutter/material.dart';
import 'package:ehnama3ak/features/resources/data/models/resource_model.dart';
import '_resource_empty.dart';
import 'pdf_viewer_screen.dart';
import 'video_player_screen.dart';
import 'package:ehnama3ak/core/widgets/full_image_page.dart';
import 'local_downloads_manager.dart';

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({super.key});

  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  List<ResourceModel> _downloads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final downloads = await LocalDownloadsManager.getDownloadedResources();
    if (mounted) {
      setState(() {
        _downloads = downloads;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDownload(int id) async {
    await LocalDownloadsManager.removeDownloadedResource(id);
    _loadDownloads();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
      );
    }

    if (_downloads.isEmpty) {
      return const ResourceEmptyView(
        icon: Icons.download_done_outlined,
        message: 'No downloads available yet.',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF1E88E5),
      onRefresh: _loadDownloads,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _downloads.length,
        itemBuilder: (_, i) => _DownloadCard(
          resource: _downloads[i],
          onDelete: () => _deleteDownload(_downloads[i].id),
        ),
      ),
    );
  }
}

class _DownloadCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onDelete;
  
  const _DownloadCard({required this.resource, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    IconData typeIcon = Icons.insert_drive_file_outlined;
    if (resource.type == ResourceType.video) typeIcon = Icons.videocam_outlined;
    if (resource.type == ResourceType.article) typeIcon = Icons.article_outlined;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _thumbnail(resource.coverImageUrl, typeIcon),
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          resource.description,
          style: const TextStyle(fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
            ElevatedButton(
              onPressed: () {
                final urlLower = resource.url.toLowerCase();
                if (resource.type == ResourceType.pdf || urlLower.endsWith('.pdf') || urlLower.contains('.pdf')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerScreen(url: resource.url, title: resource.title),
                    ),
                  );
                } else if (urlLower.endsWith('.jpg') || urlLower.endsWith('.jpeg') || urlLower.endsWith('.png') || resource.type == ResourceType.article) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullImagePage(
                        imageUrl: resource.url,
                        heroTag: 'download_${resource.id}',
                      ),
                    ),
                  );
                } else if (urlLower.endsWith('.mp4') || urlLower.endsWith('.mov') || resource.type == ResourceType.video) {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(url: resource.url, title: resource.title),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _thumbnail(String? url, IconData fallback) {
  if (url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true && url.startsWith('http')) {
    return Image.network(
      url,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _iconBox(fallback),
    );
  }
  return _iconBox(fallback);
}

Widget _iconBox(IconData icon) => Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF1E88E5), size: 30),
    );

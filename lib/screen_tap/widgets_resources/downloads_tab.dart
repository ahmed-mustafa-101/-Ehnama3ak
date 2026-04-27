import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_cubit.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_state.dart';
import 'package:ehnama3ak/features/resources/data/models/resource_model.dart';
import '_resource_empty.dart';
import '_resource_error.dart';

class DownloadsTab extends StatelessWidget {
  const DownloadsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourceCubit, ResourceState>(
      builder: (context, state) {
        if (state is ResourceLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
          );
        }

        if (state is ResourceError) {
          return ResourceErrorView(
            message: state.message,
            onRetry: () => context.read<ResourceCubit>().fetchResources(),
          );
        }

        if (state is ResourceLoaded) {
          final pdfs = state.pdfs;
          if (pdfs.isEmpty) {
            return const ResourceEmptyView(
              icon: Icons.download_rounded,
              message: 'No downloadable files available yet.',
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF1E88E5),
            onRefresh: () => context.read<ResourceCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pdfs.length,
              itemBuilder: (_, i) => _DownloadCard(resource: pdfs[i]),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Download Card ────────────────────────────────────────────────────────────

class _DownloadCard extends StatelessWidget {
  final ResourceModel resource;
  const _DownloadCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    final fileSize = resource.formattedFileSize;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Cover / icon ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _thumbnail(resource.coverImageUrl, resource.type),
            ),
            const SizedBox(width: 12),

            // ── Text ───────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.description,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileSize.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${resource.type.label} • $fileSize',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Actions ────────────────────────────────────────────────────
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _open(resource.url),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(90, 34),
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => _open(resource.url),
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

  Widget _thumbnail(String? url, ResourceType type) {
    if (url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
      return Image.network(
        url,
        width: 60,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _iconBox(type),
      );
    }
    return _iconBox(type);
  }

  Widget _iconBox(ResourceType type) {
    IconData icon;
    switch (type) {
      case ResourceType.article:
        icon = Icons.article_outlined;
        break;
      case ResourceType.video:
        icon = Icons.play_circle_outline;
        break;
      case ResourceType.pdf:
      default:
        icon = Icons.picture_as_pdf_outlined;
        break;
    }

    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF1E88E5),
        size: 30,
      ),
    );
  }
}

Future<void> _open(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

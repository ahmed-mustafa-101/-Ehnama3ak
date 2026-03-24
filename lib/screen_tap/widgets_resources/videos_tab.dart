import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_cubit.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_state.dart';
import 'package:ehnama3ak/features/resources/data/models/resource_model.dart';
import '_resource_empty.dart';
import '_resource_error.dart';

class VideosTab extends StatelessWidget {
  const VideosTab({super.key});

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
          final videos = state.videos;
          if (videos.isEmpty) {
            return const ResourceEmptyView(
              icon: Icons.videocam_outlined,
              message: 'No videos available yet.',
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF1E88E5),
            onRefresh: () => context.read<ResourceCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (_, i) => _VideoCard(resource: videos[i]),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Video Card ───────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final ResourceModel resource;
  const _VideoCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    final duration = resource.formattedDuration;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _thumbnail(resource.coverImageUrl),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
            ),
          ],
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          duration.isNotEmpty ? duration : resource.description,
          style: const TextStyle(fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _open(resource.url),
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('Watch'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(String? url) {
    if (url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
      return Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _iconBox(),
      );
    }
    return _iconBox();
  }

  Widget _iconBox() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.videocam_outlined, color: Color(0xFF1E88E5), size: 30),
      );
}

Future<void> _open(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

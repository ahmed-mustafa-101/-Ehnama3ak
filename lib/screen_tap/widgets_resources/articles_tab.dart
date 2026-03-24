import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_cubit.dart';
import 'package:ehnama3ak/features/resources/presentation/cubit/resource_state.dart';
import 'package:ehnama3ak/features/resources/data/models/resource_model.dart';
import '_resource_empty.dart';
import '_resource_error.dart';

class ArticlesTab extends StatelessWidget {
  const ArticlesTab({super.key});

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
          final articles = state.articles;
          if (articles.isEmpty) {
            return const ResourceEmptyView(
              icon: Icons.article_outlined,
              message: 'No articles available yet.',
            );
          }
          return RefreshIndicator(
            color: const Color(0xFF1E88E5),
            onRefresh: () => context.read<ResourceCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              itemBuilder: (_, i) => _ArticleCard(resource: articles[i]),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─── Article Card ─────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final ResourceModel resource;
  const _ArticleCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _thumbnail(resource.coverImageUrl, Icons.article_outlined),
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
        trailing: ElevatedButton(
          onPressed: () => _open(resource.url),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Read Now'),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _thumbnail(String? url, IconData fallback) {
  if (url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
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

Future<void> _open(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

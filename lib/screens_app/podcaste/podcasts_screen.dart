import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/localization/app_localizations.dart';
import 'package:ehnama3ak/features/podcasts/presentation/cubit/podcast_cubit.dart';
import 'package:ehnama3ak/features/podcasts/presentation/cubit/podcast_state.dart';
import 'package:ehnama3ak/features/podcasts/data/models/podcast_model.dart' as feature;
import 'models/podcast_card.dart';
import 'models/podcast_model.dart' as legacy;
import 'podcast_player_screen.dart';

class PodcastsScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  const PodcastsScreen({super.key, this.onNotificationTap});
  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PodcastCubit>().fetchPodcasts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(l10n.podcastsTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<PodcastCubit, PodcastState>(
            builder: (context, state) {
              if (state is PodcastLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xff0DA5FE)));
              }
              if (state is PodcastError) {
                return _ErrorView(message: state.message, onRetry: () => context.read<PodcastCubit>().fetchPodcasts());
              }
              if (state is PodcastLoaded) {
                if (state.podcasts.isEmpty) return const _EmptyView();
                return RefreshIndicator(
                  color: const Color(0xff0DA5FE),
                  onRefresh: () => context.read<PodcastCubit>().refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.podcasts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final podcast = state.podcasts[index];
                      final legacyModel = _toLegacyModel(podcast);
                      return PodcastCard(
                        podcast: legacyModel,
                        onPlay: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => PodcastPlayerScreen(podcast: legacyModel))),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  legacy.PodcastModel _toLegacyModel(feature.PodcastModel p) {
    return legacy.PodcastModel(
      title: p.title, subtitle: p.subtitle, audioUrl: p.audioUrl,
      duration: p.durationSeconds != null ? Duration(seconds: p.durationSeconds!) : Duration.zero,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0DA5FE), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.podcasts_rounded, size: 72, color: Color(0xff0DA5FE)),
          const SizedBox(height: 16),
          Text(l10n.noPodcasts, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 8),
          Text(l10n.checkBackLater, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

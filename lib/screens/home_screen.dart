import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/player_provider.dart';
import '../providers/search_provider.dart';
import '../providers/update_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/mini_player.dart';
import '../widgets/particle_background.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/state_views.dart';
import '../widgets/track_card.dart';
import '../widgets/update_popup.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _controller = TextEditingController();
  bool _updateChecked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeShowUpdatePopup(AsyncValue<UpdateCheckResult> updateAsync) {
    if (_updateChecked) return;

    updateAsync.whenData((result) {
      if (result.hasUpdate && result.info != null) {
        _updateChecked = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showUpdatePopup(context, result.info!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final playerState = ref.watch(playerProvider);
    final updateAsync = ref.watch(updateCheckProvider);

    _maybeShowUpdatePopup(updateAsync);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.music2,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Codec Music',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Dengar musik favoritmu',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchBarField(
                    controller: _controller,
                    onSubmitted: (value) =>
                        ref.read(searchProvider.notifier).search(value),
                    onClear: () => ref.read(searchProvider.notifier).clear(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildBody(searchState, playerState),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: MiniPlayer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState searchState, PlayerState playerState) {
    switch (searchState.status) {
      case SearchStatus.idle:
        return const EmptyView(
          icon: LucideIcons.search,
          title: 'Mulai Cari Musik',
          subtitle: 'Ketik judul lagu, nama artis, atau album di kolom pencarian.',
        );
      case SearchStatus.loading:
        return const LoadingView(message: 'Mencari lagu...');
      case SearchStatus.empty:
        return const EmptyView(
          icon: LucideIcons.searchX,
          title: 'Tidak Ditemukan',
          subtitle: 'Coba kata kunci lain yang lebih umum.',
        );
      case SearchStatus.error:
        return ErrorView(
          message: searchState.errorMessage ?? 'Terjadi kesalahan.',
          onRetry: () => ref.read(searchProvider.notifier).refresh(),
        );
      case SearchStatus.success:
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(searchProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
            itemCount: searchState.tracks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final track = searchState.tracks[index];
              final isActive = playerState.track?.spotifyUrl == track.spotifyUrl;
              return TrackCard(
                track: track,
                isActive: isActive,
                onTap: () => ref
                    .read(playerProvider.notifier)
                    .playFromList(searchState.tracks, index),
              );
            },
          ),
        );
    }
  }
}

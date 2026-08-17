import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/player_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/state_views.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final track = playerState.track;

    if (track == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: EmptyView(
          icon: LucideIcons.music,
          title: 'Belum Ada Lagu',
          subtitle: 'Pilih lagu terlebih dahulu untuk memutar.',
        ),
      );
    }

    final positionAsync = ref.watch(playerPositionProvider);
    final durationAsync = ref.watch(playerDurationProvider);

    final position = positionAsync.valueOrNull ?? Duration.zero;
    final duration = durationAsync.valueOrNull ?? Duration.zero;
    final isPlaying = playerState.status == PlaybackStatus.playing;
    final isResolving = playerState.status == PlaybackStatus.resolving;
    final hasError = playerState.status == PlaybackStatus.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Sedang Diputar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const Spacer(),
              Hero(
                tag: 'cover-${track.spotifyUrl}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: track.coverUrl,
                    width: 280,
                    height: 280,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 280,
                      height: 280,
                      color: AppColors.surface,
                      child: const Icon(
                        LucideIcons.music,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                track.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                track.artist,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    playerState.errorMessage ?? 'Gagal memutar lagu.',
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.divider,
                  thumbColor: AppColors.primary,
                ),
                child: Slider(
                  min: 0,
                  max: duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1,
                  value: position.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble(),
                  onChanged: isResolving
                      ? null
                      : (value) {
                          ref
                              .read(playerProvider.notifier)
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 28,
                    onPressed: playerState.hasPrevious
                        ? () => ref.read(playerProvider.notifier).playPrevious()
                        : null,
                    icon: const Icon(LucideIcons.skipBack),
                    color: playerState.hasPrevious
                        ? AppColors.textPrimary
                        : AppColors.divider,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: isResolving
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.6,
                            ),
                          )
                        : IconButton(
                            iconSize: 30,
                            onPressed: () =>
                                ref.read(playerProvider.notifier).togglePlayPause(),
                            icon: Icon(
                              isPlaying ? LucideIcons.pause : LucideIcons.play,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    iconSize: 28,
                    onPressed: playerState.hasNext
                        ? () => ref.read(playerProvider.notifier).playNext()
                        : null,
                    icon: const Icon(LucideIcons.skipForward),
                    color: playerState.hasNext
                        ? AppColors.textPrimary
                        : AppColors.divider,
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

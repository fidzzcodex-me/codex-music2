import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track.dart';
import '../utils/result.dart';
import 'service_providers.dart';

enum PlaybackStatus { idle, resolving, playing, paused, error }

class PlayerState {
  final Track? track;
  final PlaybackStatus status;
  final String? errorMessage;
  final List<Track> queue;
  final int queueIndex;

  const PlayerState({
    this.track,
    this.status = PlaybackStatus.idle,
    this.errorMessage,
    this.queue = const [],
    this.queueIndex = -1,
  });

  bool get hasNext => queueIndex >= 0 && queueIndex < queue.length - 1;
  bool get hasPrevious => queueIndex > 0;

  PlayerState copyWith({
    Track? track,
    PlaybackStatus? status,
    String? errorMessage,
    List<Track>? queue,
    int? queueIndex,
  }) {
    return PlayerState(
      track: track ?? this.track,
      status: status ?? this.status,
      errorMessage: errorMessage,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier(this._ref) : super(const PlayerState());

  final Ref _ref;

  Future<void> playFromList(List<Track> tracks, int index) async {
    final track = tracks[index];
    state = state.copyWith(
      track: track,
      status: PlaybackStatus.resolving,
      errorMessage: null,
      queue: tracks,
      queueIndex: index,
    );

    final api = _ref.read(musicApiServiceProvider);
    final audio = _ref.read(audioPlayerServiceProvider);

    final result = await api.resolveStreamUrl(track.spotifyUrl);

    switch (result) {
      case Success(data: final url):
        try {
          await audio.playUrl(url);
          state = state.copyWith(status: PlaybackStatus.playing);
        } on PlayerException {
          state = state.copyWith(
            status: PlaybackStatus.error,
            errorMessage: 'Gagal memutar audio. Coba lagu lain.',
          );
        } catch (_) {
          state = state.copyWith(
            status: PlaybackStatus.error,
            errorMessage: 'Terjadi kesalahan saat memutar audio.',
          );
        }
      case Failure(message: final message):
        state = state.copyWith(
          status: PlaybackStatus.error,
          errorMessage: message,
        );
    }
  }

  Future<void> togglePlayPause() async {
    final audio = _ref.read(audioPlayerServiceProvider);
    if (state.status != PlaybackStatus.playing &&
        state.status != PlaybackStatus.paused) {
      return;
    }

    if (audio.isPlaying) {
      await audio.pause();
      state = state.copyWith(status: PlaybackStatus.paused);
    } else {
      await audio.resume();
      state = state.copyWith(status: PlaybackStatus.playing);
    }
  }

  Future<void> seek(Duration position) {
    final audio = _ref.read(audioPlayerServiceProvider);
    return audio.seek(position);
  }

  Future<void> playNext() async {
    if (!state.hasNext) return;
    await playFromList(state.queue, state.queueIndex + 1);
  }

  Future<void> playPrevious() async {
    if (!state.hasPrevious) return;
    await playFromList(state.queue, state.queueIndex - 1);
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(ref);
});

final playerPositionProvider = StreamProvider<Duration>((ref) {
  final audio = ref.watch(audioPlayerServiceProvider);
  return audio.positionStream;
});

final playerDurationProvider = StreamProvider<Duration?>((ref) {
  final audio = ref.watch(audioPlayerServiceProvider);
  return audio.durationStream;
});

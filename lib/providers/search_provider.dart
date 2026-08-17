import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/track.dart';
import '../utils/result.dart';
import 'service_providers.dart';

enum SearchStatus { idle, loading, success, empty, error }

class SearchState {
  final SearchStatus status;
  final List<Track> tracks;
  final String query;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.idle,
    this.tracks = const [],
    this.query = '',
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<Track>? tracks,
    String? query,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState());

  final Ref _ref;

  Future<void> search(String query) async {
    final trimmed = query.trim();
    state = state.copyWith(query: trimmed);

    if (trimmed.isEmpty) {
      state = state.copyWith(status: SearchStatus.idle, tracks: []);
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    final api = _ref.read(musicApiServiceProvider);
    final result = await api.search(trimmed);

    switch (result) {
      case Success(data: final tracks):
        state = state.copyWith(
          status: tracks.isEmpty ? SearchStatus.empty : SearchStatus.success,
          tracks: tracks,
        );
      case Failure(message: final message):
        state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: message,
        );
    }
  }

  Future<void> refresh() => search(state.query);

  void clear() {
    state = const SearchState();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

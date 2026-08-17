import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_player_service.dart';
import '../services/music_api_service.dart';
import '../services/update_service.dart';

final musicApiServiceProvider = Provider<MusicApiService>((ref) {
  return MusicApiService();
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

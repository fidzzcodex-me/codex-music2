class Track {
  final String title;
  final String artist;
  final String album;
  final String coverUrl;
  final String spotifyUrl;
  final String duration;

  const Track({
    required this.title,
    required this.artist,
    required this.album,
    required this.coverUrl,
    required this.spotifyUrl,
    required this.duration,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      title: (json['title'] ?? json['name'] ?? 'Unknown Title').toString(),
      artist: _parseArtist(json['artist'] ?? json['artists']),
      album: (json['album'] ?? '-').toString(),
      coverUrl: (json['cover'] ?? json['image'] ?? json['thumbnail'] ?? '')
          .toString(),
      spotifyUrl: (json['url'] ?? json['spotifyUrl'] ?? json['link'] ?? '')
          .toString(),
      duration: _parseDuration(json['duration']),
    );
  }

  static String _parseArtist(dynamic value) {
    if (value == null) return 'Unknown Artist';
    if (value is List) return value.join(', ');
    return value.toString();
  }

  static String _parseDuration(dynamic value) {
    if (value == null) return '--:--';
    if (value is num) {
      final totalSeconds = value > 1000 ? (value ~/ 1000) : value.toInt();
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }
}

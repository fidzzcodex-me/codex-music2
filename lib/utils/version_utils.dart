/// Membandingkan dua string versi semver (mis. "1.2.0" vs "1.10.0").
/// Return true jika [remote] lebih baru dari [current].
bool isNewerVersion(String current, String remote) {
  final currentParts = _parse(current);
  final remoteParts = _parse(remote);

  final length = currentParts.length > remoteParts.length
      ? currentParts.length
      : remoteParts.length;

  for (var i = 0; i < length; i++) {
    final c = i < currentParts.length ? currentParts[i] : 0;
    final r = i < remoteParts.length ? remoteParts[i] : 0;
    if (r > c) return true;
    if (r < c) return false;
  }
  return false;
}

List<int> _parse(String version) {
  return version
      .split('+')
      .first
      .split('.')
      .map((e) => int.tryParse(e.trim()) ?? 0)
      .toList();
}

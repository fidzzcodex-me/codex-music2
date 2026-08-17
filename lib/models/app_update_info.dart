class AppUpdateInfo {
  final String latestVersion;
  final String? changelog;
  final String? apkUrl;
  final String? playStoreUrl;

  const AppUpdateInfo({
    required this.latestVersion,
    this.changelog,
    this.apkUrl,
    this.playStoreUrl,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestVersion: (json['version'] ?? json['latestVersion'] ?? '0.0.0')
          .toString(),
      changelog: json['changelog']?.toString(),
      apkUrl: json['apkUrl']?.toString(),
      playStoreUrl: json['playStoreUrl']?.toString(),
    );
  }
}

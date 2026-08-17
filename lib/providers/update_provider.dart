import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_update_info.dart';
import '../utils/result.dart';
import '../utils/version_utils.dart';
import 'service_providers.dart';

class UpdateCheckResult {
  final bool hasUpdate;
  final AppUpdateInfo? info;
  final String currentVersion;

  const UpdateCheckResult({
    required this.hasUpdate,
    required this.currentVersion,
    this.info,
  });
}

final updateCheckProvider = FutureProvider<UpdateCheckResult>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;

  final service = ref.read(updateServiceProvider);
  final result = await service.checkForUpdate();

  switch (result) {
    case Success(data: final info):
      final hasUpdate = isNewerVersion(currentVersion, info.latestVersion);
      return UpdateCheckResult(
        hasUpdate: hasUpdate,
        currentVersion: currentVersion,
        info: info,
      );
    case Failure():
      return UpdateCheckResult(
        hasUpdate: false,
        currentVersion: currentVersion,
      );
  }
});

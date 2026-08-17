import 'package:dio/dio.dart';

import '../models/app_update_info.dart';
import '../utils/result.dart';

/// Endpoint pengecekan versi. Sesuaikan jika backend versi resmi tersedia.
class UpdateService {
  UpdateService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;
  static const String _versionEndpoint =
      'https://me.fidzzcodex.my.id/version/codec-music';

  Future<Result<AppUpdateInfo>> checkForUpdate() async {
    try {
      final response = await _dio.get(_versionEndpoint);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final result = data['result'] is Map<String, dynamic>
            ? data['result'] as Map<String, dynamic>
            : data;
        return Success(AppUpdateInfo.fromJson(result));
      }

      return const Failure('Format data update tidak dikenali.');
    } on DioException {
      return const Failure('Gagal memeriksa update.');
    } catch (_) {
      return const Failure('Terjadi kesalahan saat memeriksa update.');
    }
  }
}

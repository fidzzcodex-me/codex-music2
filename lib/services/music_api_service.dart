import 'package:dio/dio.dart';

import '../models/track.dart';
import '../utils/result.dart';

class MusicApiService {
  MusicApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://me.fidzzcodex.my.id',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final Dio _dio;
  static const String _apiKey = 'fidzzcodex';

  Future<Result<List<Track>>> search(String query) async {
    if (query.trim().isEmpty) {
      return const Success<List<Track>>([]);
    }

    try {
      final response = await _dio.get(
        '/search/spotify',
        queryParameters: {'apikey': _apiKey, 'q': query},
      );

      final rawResults = _extractList(response.data);
      final tracks = rawResults
          .whereType<Map<String, dynamic>>()
          .map(Track.fromJson)
          .toList();

      return Success(tracks);
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (_) {
      return const Failure('Terjadi kesalahan tak terduga saat mencari lagu.');
    }
  }

  Future<Result<String>> resolveStreamUrl(String spotifyUrl) async {
    try {
      final response = await _dio.post(
        '/download/spotify',
        data: {'apikey': _apiKey, 'url': spotifyUrl},
      );

      final data = response.data;
      final result = data is Map<String, dynamic> ? data['result'] : null;
      final links = result is Map<String, dynamic> ? result['links'] : null;
      final mp3 = links is Map<String, dynamic> ? links['mp3'] : null;

      if (mp3 == null || mp3.toString().isEmpty) {
        return const Failure('Link audio tidak ditemukan untuk lagu ini.');
      }

      return Success(mp3.toString());
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (_) {
      return const Failure('Gagal memuat sumber audio.');
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final result = data['result'] ?? data['data'] ?? data['tracks'];
      if (result is List) return result;
    }
    return const [];
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa jaringan kamu.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 404) return 'Data tidak ditemukan.';
        if (status != null && status >= 500) return 'Server sedang bermasalah.';
        return 'Permintaan gagal (kode $status).';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
}

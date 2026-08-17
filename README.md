# Codec Music

Aplikasi streaming musik minimalis bertema **Blue & White Soft**, dibangun dengan Flutter + Riverpod. Streaming langsung (tidak menyimpan file permanen) menggunakan `just_audio`.

- Package: `com.codec.music`
- State management: Riverpod
- Audio: just_audio + audio_session
- HTTP: dio

## Struktur Proyek

```
lib/
  main.dart
  models/           # Track, AppUpdateInfo
  services/         # MusicApiService, UpdateService, AudioPlayerService
  providers/        # search, player, update, service providers (Riverpod)
  screens/          # HomeScreen (search + list), PlayerScreen (full player)
  widgets/          # TrackCard, MiniPlayer, ParticleBackground, UpdatePopup, dll
  utils/            # AppColors, Result<T>, version comparator
android/            # Native project, package com.codec.music
.github/workflows/  # CI build APK otomatis
```

## Cara Build Lokal

1. Pastikan Flutter SDK stable sudah terpasang (`flutter --version`).
2. Install dependency:
   ```bash
   flutter pub get
   ```
3. Cek kualitas kode (harus tanpa error/warning):
   ```bash
   flutter analyze
   ```
4. Jalankan di device/emulator:
   ```bash
   flutter run
   ```
5. Build APK release:
   ```bash
   flutter build apk --release
   ```
   Hasil APK ada di `build/app/outputs/flutter-apk/app-release.apk`.

## Build Otomatis (GitHub Actions)

Setiap push ke branch `main` akan otomatis:
1. Setup Flutter stable + Java 17
2. `flutter pub get`
3. `flutter analyze`
4. `flutter build apk --release`
5. Upload APK sebagai artifact (`codec-music-release-apk`), bisa diunduh dari tab **Actions** di repo.

Bisa juga dipicu manual lewat tab Actions → **Run workflow**.

## Integrasi API

- **Search**: `GET https://me.fidzzcodex.my.id/search/spotify?apikey=fidzzcodex&q={keyword}`
- **Resolve stream URL**: `POST https://me.fidzzcodex.my.id/download/spotify` dengan body `{ "apikey": "fidzzcodex", "url": "{spotifyUrl}" }`, link MP3 diambil dari `result.links.mp3`.

Parser response di `Track.fromJson` dan `MusicApiService.resolveStreamUrl` dibuat toleran terhadap variasi nama field (`title`/`name`, `cover`/`image`/`thumbnail`, dll). Jika struktur JSON asli API berbeda dari asumsi ini, sesuaikan mapping di:
- `lib/models/track.dart`
- `lib/services/music_api_service.dart`

## Cek Update Aplikasi

`UpdateService` memanggil endpoint `https://me.fidzzcodex.my.id/version/codec-music` (placeholder — ganti ke endpoint versi resmi kamu) yang diharapkan mengembalikan JSON berisi `version`, `changelog`, `apkUrl`, dan/atau `playStoreUrl`. Jika versi remote lebih baru dari versi lokal (`pubspec.yaml` → `version:`), popup update custom akan tampil otomatis saat app dibuka.

## Catatan Audio Background

Project ini menggunakan `just_audio` + `audio_session` (sesuai spesifikasi), yang menangani audio focus dan interruption dengan baik selama proses aplikasi aktif/di-minimize. Untuk kontrol media penuh dari lockscreen/notification (media session Android), diperlukan paket tambahan `audio_service` yang **tidak** termasuk dalam scope proyek ini — bisa ditambahkan belakangan tanpa mengubah arsitektur `AudioPlayerService` yang sudah ada.

## Lint & Kualitas Kode

Proyek menggunakan `flutter_lints` (`analysis_options.yaml`). Jalankan `flutter analyze` sebelum commit untuk memastikan tidak ada error/warning.

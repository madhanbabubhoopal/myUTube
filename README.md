# KidsTube 🎬

A YouTube-style local video player for kids. Works **100% offline** — plays videos stored on your Android device. No internet, no ads, no unsafe content.

## Target Device

- Redmi 13C with Xiaomi HyperOS 2.0.2.3.0 (Android 13)
- Min SDK: 24 (Android 7.0+), Target SDK: 33 (Android 13)

---

## Features

| Feature | Details |
|---|---|
| YouTube-style UI | Red header, bottom nav (5 tabs), video cards with thumbnails |
| Home Feed | Vertical scroll, staggered animations, duration badges |
| Clips Tab | Full-screen vertical swipe feed (YouTube Shorts style) |
| Folders Tab | Browse videos grouped by device folder |
| Search | Instant search by filename/folder |
| Video Player | Inline (40% top + Up Next list) + Fullscreen mode |
| Fullscreen | Swipe-up tray for next 5 videos, swipe/double-tap seeks, lock button |
| Parental Lock | 4-digit PIN gates Settings screen (default PIN: **1234**) |
| Hide Folders | Remove folders from home feed via three-dot menu or Settings |
| Dark Mode | Toggle in Settings (persists across restarts) |
| Autoplay | Plays next video in folder automatically |
| Shuffle | Randomises playback order |
| Offline-first | Zero network calls; video list cached in SharedPreferences |

## Supported Video Formats

`.mp4` `.mkv` `.avi` `.mov` `.3gp` `.webm`

---

## Build & Run

### Prerequisites

- Flutter SDK (stable) — [install guide](https://docs.flutter.dev/get-started/install)
- Android SDK (API 33+)
- Java 11+
- USB debugging enabled on the Redmi 13C

### Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Run in debug mode on connected device
flutter run

# 3. Build release APK
flutter build apk --release

# 4. The APK is at:
#    build/app/outputs/flutter-apk/app-release.apk
```

### Install release APK via ADB

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## First Launch

1. The app requests **Read Media Video** permission (Android 13+) or **Read External Storage** (older).
2. On Xiaomi/HyperOS devices, if the system dialog doesn't appear, go to **Settings → Apps → KidsTube → Permissions** and grant storage access manually.
3. Once granted, the app scans your device and displays all videos grouped by folder.

---

## Project Structure

```
lib/
├── main.dart                      Entry point
├── app.dart                       Root widget, theme setup, main shell
├── models/
│   └── video_item.dart            Data model + JSON serialisation
├── providers/
│   └── video_provider.dart        ChangeNotifier: scan, search, settings
├── screens/
│   ├── home_screen.dart           Home feed (vertical video cards)
│   ├── clips_screen.dart          Shorts-style vertical swipe feed
│   ├── library_screen.dart        Folder browser + folder detail
│   ├── search_screen.dart         Real-time filename search
│   ├── player_screen.dart         Video player (inline + fullscreen)
│   └── settings_screen.dart       Settings (PIN-gated)
├── widgets/
│   ├── kidstube_logo.dart         Logo (CustomPainter — no image files)
│   ├── video_card.dart            Thumbnail card used in feed + search
│   ├── player_controls.dart       Fullscreen overlay controls
│   ├── swipe_video_tray.dart      Horizontal "Up Next" tray in fullscreen
│   └── bottom_nav.dart            5-tab bottom navigation bar
└── utils/
    ├── video_scanner.dart         photo_manager-based device scanner
    └── thumbnail_helper.dart      Background isolate thumbnail generator
```

---

## Parental Controls

- Default PIN: **1234**
- The PIN gates the Settings screen (Profile tab)
- In Settings you can: change PIN, hide/unhide folders, toggle dark mode, autoplay, shuffle
- Hidden folders are excluded from the Home feed (still visible in Folders tab with a hidden indicator)

---

## Technical Notes

- **VideoPlayerController.file(File(path))** — correct API for Android 13 local files
- **photo_manager `getAssetListRange()`** — used instead of `getAssetListPaged()` to avoid a MIUI pagination bug
- **Thumbnail generation** runs in a background Dart isolate via `compute()` — no UI jank
- **IndexedStack** keeps all tabs in memory — scroll position preserved on tab switch
- **SharedPreferences** caches the video list — fast startup even with 1000s of videos

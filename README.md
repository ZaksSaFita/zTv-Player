# zTv Player

<p align="center">
  <img src="ztv_player/assets/images/zTv_logo.png" alt="zTv Player logo" width="180" />
</p>

<p align="center">
  A modern <b>Flutter IPTV / Xtream Codes</b> player for Live TV, Movies, and Series with local playlist storage, EPG support, and a multi-playlist workflow.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter badge" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart badge" />
  <img src="https://img.shields.io/badge/Hive-Local%20Storage-F2C94C?style=for-the-badge&logo=databricks&logoColor=111111" alt="Hive badge" />
  <img src="https://img.shields.io/badge/Better%20Player-Video%20Playback-1F2937?style=for-the-badge" alt="Better Player badge" />
</p>

## ✨ Overview

`zTv Player` is a Flutter application for IPTV playback using `Xtream Codes` credentials. The project is designed to let users quickly add a playlist, keep it stored locally, and immediately browse:

- `Live TV` channels and categories
- `Movies` catalog
- `Series` catalog
- `EPG` data and archive playback
- multiple playlists from one app

## 🚀 Features

- 📺 `Live TV` browsing by category and channel
- 🎬 `Movies` browsing and playback
- 📚 `Series` browsing with seasons and episodes
- 🕒 `EPG` support for program information
- ⏪ `Archive playback` for supported live channels
- 💾 local playlist and active-session persistence with `Hive`
- 🔄 reload and edit existing playlists from `Settings`
- 🔍 search, sorting, and view mode switching across content sections
- 🎨 built-in theme switching
- 🧱 clear separation of `models`, `services`, `storage`, `screens`, and `widgets`

## 🧰 Tech Stack

- `Flutter`
- `Dart`
- `Dio` for HTTP communication
- `Hive` / `hive_flutter` for local storage
- `json_serializable` / `json_annotation` for models
- `better_player_plus` for video playback
- `cached_network_image` for posters and remote images

## 🗂️ Project Structure

The Flutter app currently lives inside the [`ztv_player`](./ztv_player) folder.

```text
zTv-Player/
├─ README.md
├─ better_player documentation/
└─ ztv_player/
   ├─ lib/
   │  ├─ helpers/
   │  ├─ models/
   │  ├─ screens/
   │  ├─ services/
   │  ├─ storage/
   │  └─ widgets/
   ├─ assets/
   ├─ test/
   └─ pubspec.yaml
```

## ⚡ Quick Start

```bash
cd ztv_player
flutter pub get
flutter run
```

## 🛠️ Useful Commands

```bash
cd ztv_player
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

## 🧭 How It Works

1. The app initializes `Hive` boxes and loads saved settings.
2. The active playlist is restored from local storage.
3. The playlist snapshot is hydrated into local boxes for `Live`, `Movies`, and `Series`.
4. The UI reads local data and renders categories, lists, and detail screens.
5. `PlaybackService` builds stream URLs for live, movie, series, and archive playback.

## 📱 App Flow

- `Create Playlist` screen for server, username, and password input
- `MainScreen` with tabs: `Live`, `Movies`, `Series`, `Settings`
- `Settings` includes:
  - switching the active playlist
  - reloading an existing playlist
  - editing playlist credentials
  - deleting a playlist
  - changing the app theme

## 🧪 Testing

The project already includes tests for parts of the helper, service, and storage layers, including:

- sort helper
- network URL normalization
- media format helper
- playback service
- Xtream API service
- playlist repository

## ⚠️ Notes

- User credentials and playlist metadata are currently stored locally.
- Some IPTV servers return inconsistent JSON, so the service layer performs extra response sanitization.
- The app is functional, but the codebase is still being cleaned up and refactored.

## 🛣️ Roadmap

- broader test coverage across services and UI
- less duplication in the UI layer
- safer handling of sensitive data
- continued cleanup of architecture and reusable flows

## 🤝 Status

The project is active and already supports a real IPTV / Xtream Codes workflow, with ongoing work focused on more stable playback, a cleaner UI layer, and a better organized codebase.


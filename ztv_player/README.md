# zTv Player

<p align="center">
  <img src="assets/images/zTv_logo.png" alt="zTv Player logo" width="180" />
</p>

<p align="center">
  A modern <b>Flutter IPTV / Xtream Codes</b> player for Live TV, Movies, and Series with local playlist storage, EPG support, and a multi-playlist workflow.
</p>

## ✨ Overview

`zTv Player` is a Flutter application for IPTV playback using `Xtream Codes` credentials. It is built to help users quickly create a playlist, keep it stored locally, and browse content in a clean and structured way.

## 🚀 Features

- 📺 multiple playlist support
- 🗂️ Live TV categories and channels
- 🎬 Movies catalog and playback
- 📚 Series catalog with seasons and episodes
- 🕒 EPG loading and archive playback
- 💾 local persistence with `Hive`
- 🔄 playlist reload and edit flow
- 🔍 search, sorting, and content view switching
- 🎨 theme switching from settings

## 🧰 Tech Stack

- `Flutter`
- `Dart`
- `Dio` for HTTP communication
- `Hive` and `hive_flutter` for local storage
- `json_serializable` and `json_annotation` for models
- `better_player_plus` for video playback
- `cached_network_image` for posters and remote images

## 🗂️ Project Structure

- `lib/main.dart`  
  App startup, Hive bootstrap, theme loading, and root navigation.
- `lib/models`  
  Domain models for playlists, Live TV, VOD, series, and EPG.
- `lib/services`  
  API, playback, settings, and playlist orchestration logic.
- `lib/storage`  
  Repository layer for playlist persistence and active snapshot handling.
- `lib/screens`  
  Main UI flow for playlist setup, browsing, and playback.
- `lib/widgets`  
  Reusable UI components and shared content presentation widgets.
- `test`  
  Unit tests for helpers, services, and storage logic.

## 🧭 Main App Flow

1. The app initializes Hive and opens local boxes.
2. The active playlist is restored from storage.
3. The active playlist snapshot is hydrated into local content boxes.
4. Screens read from those boxes and render Live TV, Movies, and Series sections.
5. Detail pages and playback use the active playlist to resolve Xtream API stream URLs.

## ⚡ Getting Started

1. Install the Flutter SDK.
2. Run `flutter pub get`.
3. Start the app with `flutter run`.

## 🛠️ Useful Commands

- `flutter pub get`
- `flutter run`
- `flutter test`
- `flutter analyze`
- `dart run build_runner build --delete-conflicting-outputs`

## ⚠️ Development Notes

- The active playlist is currently stored locally.
- Some IPTV servers return inconsistent JSON, so `XtreamApiService` includes additional response sanitization.
- The project is already functional, but the codebase is still going through cleanup and refactoring.

## 🛣️ Current Priorities

- broader test coverage for services and repository logic
- safer handling of sensitive data
- reducing remaining duplicated flows in player and detail screens
- replacing fragile package-internal dependencies with more stable APIs

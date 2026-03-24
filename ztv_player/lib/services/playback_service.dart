import 'package:ztv_player/models/episode.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_channel.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/services/settings_service.dart';

class PlaybackService {
  const PlaybackService({this.settingsService = const SettingsService()});

  final SettingsService settingsService;

  String? resolveLiveStreamUrl(LiveChannel channel) {
    final directSource = _normalizedDirectSource(channel.streamUrl);
    if (directSource != null) {
      return directSource;
    }

    final playlist = settingsService.getCurrentPlaylist();
    if (playlist == null) {
      return null;
    }

    final server = _normalizedServer(playlist.server);
    return '$server/live/${playlist.username}/${playlist.password}/${channel.id}.ts';
  }

  String? resolveMovieStreamUrl(VodMovie movie, {String extension = 'mp4'}) {
    final directSource = _normalizedDirectSource(movie.streamUrl);
    if (directSource != null) {
      return directSource;
    }

    final playlist = settingsService.getCurrentPlaylist();
    if (playlist == null) {
      return null;
    }

    final server = _normalizedServer(playlist.server);
    return '$server/movie/${playlist.username}/${playlist.password}/${movie.id}.$extension';
  }

  String? resolveEpisodeStreamUrl(Episode episode, {String extension = 'mp4'}) {
    final directSource = _normalizedDirectSource(episode.streamUrl);
    if (directSource != null) {
      return directSource;
    }

    final playlist = settingsService.getCurrentPlaylist();
    if (playlist == null) {
      return null;
    }

    final server = _normalizedServer(playlist.server);
    return '$server/series/${playlist.username}/${playlist.password}/${episode.id}.$extension';
  }

  String? resolveArchiveStreamUrl({
    required LiveChannel channel,
    required EpgListing listing,
  }) {
    if (!listing.hasArchive) {
      return null;
    }

    final playlist = settingsService.getCurrentPlaylist();
    if (playlist == null) {
      return null;
    }

    final server = _normalizedServer(playlist.server);
    final duration = _archiveDurationMinutes(listing);
    final start = _formatArchiveStart(listing.start);
    return '$server/timeshift/${playlist.username}/${playlist.password}/$duration/$start/${channel.id}.ts';
  }

  String? _normalizedDirectSource(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String _normalizedServer(String server) {
    return server.endsWith('/')
        ? server.substring(0, server.length - 1)
        : server;
  }

  int _archiveDurationMinutes(EpgListing listing) {
    final minutes = listing.end.difference(listing.start).inMinutes;
    return minutes <= 0 ? 1 : minutes;
  }

  String _formatArchiveStart(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day:$hour-$minute';
  }
}

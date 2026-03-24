import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:ztv_player/models/episode.dart';
import 'package:ztv_player/models/season.dart';
import 'package:ztv_player/models/series.dart';
import 'package:ztv_player/models/series_details.dart';
import 'package:ztv_player/services/playback_service.dart';
import 'package:ztv_player/services/series_service.dart';
import 'package:ztv_player/widgets/app_video_player.dart';
import 'package:ztv_player/widgets/media_detail_scaffold.dart';

class SeriesPlayerScreen extends StatefulWidget {
  SeriesPlayerScreen({
    super.key,
    required this.series,
    this.playbackService = const PlaybackService(),
    SeriesService? seriesService,
  }) : seriesService = seriesService ?? SeriesService();

  final Series series;
  final PlaybackService playbackService;
  final SeriesService seriesService;

  @override
  State<SeriesPlayerScreen> createState() => _SeriesPlayerScreenState();
}

class _SeriesPlayerScreenState extends State<SeriesPlayerScreen> {
  Episode? _selectedEpisode;
  late final Future<SeriesDetails> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = widget.seriesService.getSeriesDetails(widget.series.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SeriesDetails>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final details = snapshot.data;
        final playlistEntries = details == null
            ? const <_EpisodePlaylistEntry>[]
            : _buildPlaylistEntries(_allEpisodes(details));
        final episodes = [
          for (final entry in playlistEntries) entry.episode,
        ];
        final selectedEpisode = _selectedEpisode;
        final selectedIndex = selectedEpisode == null
            ? -1
            : episodes.indexWhere((episode) => episode.id == selectedEpisode.id);
        final streamUrl = _selectedEpisode == null
            ? null
            : widget.playbackService.resolveEpisodeStreamUrl(
                _selectedEpisode!,
                extension: _selectedEpisode!.containerExtension ?? 'mp4',
              );
        final playlistDataSources = playlistEntries.isEmpty
            ? null
            : [
                for (final entry in playlistEntries) entry.dataSource,
              ];

        return MediaDetailScaffold(
          title: _selectedEpisode?.name ?? widget.series.name,
          player: AppVideoPlayer(
            streamUrl: streamUrl,
            playlistDataSources: selectedIndex >= 0 ? playlistDataSources : null,
            initialPlaylistIndex: selectedIndex >= 0 ? selectedIndex : 0,
            placeholderImageUrl:
                _selectedEpisode?.logoUrl ?? widget.series.logoUrl,
            autoInitialize: selectedIndex >= 0,
            isLiveStream: false,
            onPlaylistIndexChanged: selectedIndex < 0
                ? null
                : (index) {
                    if (index < 0 || index >= episodes.length) {
                      return;
                    }
                    final nextEpisode = episodes[index];
                    if (_selectedEpisode?.id == nextEpisode.id) {
                      return;
                    }
                    setState(() => _selectedEpisode = nextEpisode);
                  },
            idleTitle: _selectedEpisode == null
                ? 'Select an episode to start playback.'
                : null,
          ),
          content: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || details == null) {
                return _SeriesFallbackDetails(series: widget.series);
              }

              return _SeriesDetailsContent(
                series: widget.series,
                details: details,
                selectedEpisode: _selectedEpisode,
                onEpisodeSelected: (episode) {
                  setState(() => _selectedEpisode = episode);
                },
              );
            },
          ),
        );
      },
    );
  }

  List<Episode> _allEpisodes(SeriesDetails details) {
    return [
      for (final season in details.seasons) ...season.episodes,
    ];
  }

  List<_EpisodePlaylistEntry> _buildPlaylistEntries(List<Episode> episodes) {
    final entries = <_EpisodePlaylistEntry>[];

    for (final episode in episodes) {
      final streamUrl = widget.playbackService.resolveEpisodeStreamUrl(
        episode,
        extension: episode.containerExtension ?? 'mp4',
      );
      if (streamUrl == null || streamUrl.trim().isEmpty) {
        continue;
      }

      entries.add(
        _EpisodePlaylistEntry(
          episode: episode,
          dataSource: BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            streamUrl,
            liveStream: false,
            videoFormat: _detectVideoFormat(streamUrl),
            notificationConfiguration:
                const BetterPlayerNotificationConfiguration(
                  showNotification: false,
                ),
          ),
        ),
      );
    }

    return entries;
  }

  BetterPlayerVideoFormat? _detectVideoFormat(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8')) {
      return BetterPlayerVideoFormat.hls;
    }
    if (lower.contains('.mpd')) {
      return BetterPlayerVideoFormat.dash;
    }
    return null;
  }
}

class _EpisodePlaylistEntry {
  const _EpisodePlaylistEntry({
    required this.episode,
    required this.dataSource,
  });

  final Episode episode;
  final BetterPlayerDataSource dataSource;
}

class _SeriesDetailsContent extends StatelessWidget {
  const _SeriesDetailsContent({
    required this.series,
    required this.details,
    required this.selectedEpisode,
    required this.onEpisodeSelected,
  });

  final Series series;
  final SeriesDetails details;
  final Episode? selectedEpisode;
  final ValueChanged<Episode> onEpisodeSelected;

  @override
  Widget build(BuildContext context) {
    final seasons = details.seasons;
    if (seasons.isEmpty) {
      return _SeriesFallbackDetails(series: series, details: details);
    }

    return DefaultTabController(
      length: seasons.length,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF23232D),
            child: TabBar(
              isScrollable: true,
              indicatorColor: Colors.tealAccent,
              labelColor: Colors.tealAccent,
              unselectedLabelColor: Colors.white70,
              tabs: seasons
                  .map(
                    (season) => Tab(
                      text: season.name?.trim().isNotEmpty == true
                          ? season.name!
                          : 'Season ${season.seasonNumber}',
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: seasons
                  .map(
                    (season) => _SeasonEpisodesPanel(
                      season: season,
                      selectedEpisode: selectedEpisode,
                      onEpisodeSelected: onEpisodeSelected,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonEpisodesPanel extends StatelessWidget {
  const _SeasonEpisodesPanel({
    required this.season,
    required this.selectedEpisode,
    required this.onEpisodeSelected,
  });

  final Season season;
  final Episode? selectedEpisode;
  final ValueChanged<Episode> onEpisodeSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SeriesInfoCard(season: season),
        const SizedBox(height: 16),
        ...season.episodes.map(
          (episode) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: selectedEpisode?.id == episode.id
                  ? Colors.white10
                  : const Color(0xFF2B2B35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedEpisode?.id == episode.id
                    ? Colors.tealAccent
                    : Colors.transparent,
              ),
            ),
            child: ListTile(
              selected: selectedEpisode?.id == episode.id,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.tealAccent.withValues(alpha: 0.15),
                child: Text(
                  episode.episodeNumber.toString(),
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                episode.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: _episodeSubtitle(episode),
              trailing: const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.tealAccent,
              ),
              onTap: () => onEpisodeSelected(episode),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _episodeSubtitle(Episode episode) {
    final parts = <String>[];
    if (episode.duration != null && episode.duration!.isNotEmpty) {
      parts.add(episode.duration!);
    }
    if (episode.rating != null && episode.rating!.isNotEmpty) {
      parts.add('Rating ${_formatRating(episode.rating)}');
    }
    if (parts.isEmpty) {
      return null;
    }

    return Text(
      parts.join(' • '),
      style: const TextStyle(color: Colors.white54),
    );
  }
}

class _SeriesInfoCard extends StatelessWidget {
  const _SeriesInfoCard({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[];
    if (season.voteAverage != null && season.voteAverage!.isNotEmpty) {
      lines.add('Rating ${_formatRating(season.voteAverage)}');
    }
    if (season.episodeCount != null) {
      lines.add('${season.episodeCount} episodes');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lines.isNotEmpty)
            Text(
              lines.join(' • '),
              style: const TextStyle(color: Colors.white70),
            ),
          if (season.overview != null && season.overview!.isNotEmpty) ...[
            if (lines.isNotEmpty) const SizedBox(height: 10),
            Text(
              season.overview!,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _SeriesFallbackDetails extends StatelessWidget {
  const _SeriesFallbackDetails({required this.series, this.details});

  final Series series;
  final SeriesDetails? details;

  @override
  Widget build(BuildContext context) {
    final description = details?.plot ?? series.plot;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B35),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details?.name ?? series.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SeriesInfoRow(label: 'Genre', value: details?.genre ?? series.genre),
        _SeriesInfoRow(
          label: 'Rating',
          value: _formatNullableRating(details?.rating ?? series.rating),
        ),
        _SeriesInfoRow(
          label: 'Release',
          value: details?.releaseDate ?? series.year,
        ),
        _SeriesInfoRow(
          label: 'Director',
          value: details?.director ?? series.director,
        ),
        _SeriesInfoRow(label: 'Cast', value: details?.cast ?? series.cast),
      ],
    );
  }
}

class _SeriesInfoRow extends StatelessWidget {
  const _SeriesInfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final resolvedValue = value;
    if (resolvedValue == null || resolvedValue.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              resolvedValue,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatRating(String? value) {
  final rating = double.tryParse(value ?? '');
  if (rating == null) {
    return value ?? '';
  }

  return rating.toStringAsFixed(2);
}

String? _formatNullableRating(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return _formatRating(value);
}

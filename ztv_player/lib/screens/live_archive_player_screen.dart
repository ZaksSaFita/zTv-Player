import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/services/favorites_service.dart';
import 'package:ztv_player/services/playback_service.dart';
import 'package:ztv_player/widgets/enhanced_video_player.dart';
import 'package:ztv_player/widgets/labeled_value_row.dart';
import 'package:ztv_player/widgets/media_detail_scaffold.dart';

class LiveArchivePlayerScreen extends StatefulWidget {
  const LiveArchivePlayerScreen({
    super.key,
    required this.channel,
    required this.listing,
    this.playbackService = const PlaybackService(),
  });

  final LiveTvChannel channel;
  final EpgListing listing;
  final PlaybackService playbackService;

  @override
  State<LiveArchivePlayerScreen> createState() =>
      _LiveArchivePlayerScreenState();
}

class _LiveArchivePlayerScreenState extends State<LiveArchivePlayerScreen> {
  late final ValueNotifier<bool> _isPlayingNotifier;
  late final ValueNotifier<bool> _isFavoriteNotifier;
  BetterPlayerController? _playerController;
  final FavoritesService _favoritesService = const FavoritesService();

  @override
  void initState() {
    super.initState();
    final isFavorite = _favoritesService.isFavorite(
      FavoriteContentType.liveTv,
      widget.channel.id,
    );
    _isFavoriteNotifier = ValueNotifier(isFavorite);
    _isPlayingNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _isPlayingNotifier.dispose();
    _isFavoriteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamUrl = widget.playbackService.resolveArchiveStreamUrl(
      channel: widget.channel,
      listing: widget.listing,
    );

    return MediaDetailScaffold(
      title: widget.listing.title.isEmpty
          ? widget.channel.name
          : widget.listing.title,
      player: EnhancedVideoPlayer(
        streamUrl: streamUrl,
        placeholderImageUrl: widget.channel.logoUrl,
        isLiveStream: true,
        onControllerReady: (controller) => _playerController = controller,
        onFavoriteToggle: _toggleFavorite,
        isFavorite: _isFavoriteNotifier.value,
      ),
      content: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ArchiveInfoCard(channel: widget.channel, listing: widget.listing),
          const SizedBox(height: 16),
          LabeledValueRow(label: 'Stream ID', value: widget.channel.id),
          LabeledValueRow(
            label: 'Time',
            value:
                '${_formatTime(widget.listing.start)} - ${_formatTime(widget.listing.end)}',
          ),
          LabeledValueRow(
            label: 'Archive',
            value: widget.listing.hasArchive ? 'Available' : 'Unavailable',
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _toggleFavorite() {
    final isFavorite = _favoritesService.toggleFavorite(
      FavoriteContentType.liveTv,
      widget.channel.id,
    );
    _isFavoriteNotifier.value = isFavorite;
  }
}

class _ArchiveInfoCard extends StatelessWidget {
  const _ArchiveInfoCard({required this.channel, required this.listing});

  final LiveTvChannel channel;
  final EpgListing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.title.isEmpty ? channel.name : listing.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (listing.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              listing.description,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

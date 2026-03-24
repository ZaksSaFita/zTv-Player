import 'package:flutter/material.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_channel.dart';
import 'package:ztv_player/services/playback_service.dart';
import 'package:ztv_player/widgets/app_video_player.dart';
import 'package:ztv_player/widgets/media_detail_scaffold.dart';

class LiveArchivePlayerScreen extends StatelessWidget {
  const LiveArchivePlayerScreen({
    super.key,
    required this.channel,
    required this.listing,
    this.playbackService = const PlaybackService(),
  });

  final LiveChannel channel;
  final EpgListing listing;
  final PlaybackService playbackService;

  @override
  Widget build(BuildContext context) {
    final streamUrl = playbackService.resolveArchiveStreamUrl(
      channel: channel,
      listing: listing,
    );

    return MediaDetailScaffold(
      title: listing.title.isEmpty ? channel.name : listing.title,
      player: AppVideoPlayer(
        streamUrl: streamUrl,
        placeholderImageUrl: channel.logoUrl,
      ),
      content: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ArchiveInfoCard(channel: channel, listing: listing),
          const SizedBox(height: 16),
          _ArchiveRow(label: 'Stream ID', value: channel.id),
          _ArchiveRow(
            label: 'Time',
            value: '${_formatTime(listing.start)} - ${_formatTime(listing.end)}',
          ),
          _ArchiveRow(
            label: 'Archive',
            value: listing.hasArchive ? 'Available' : 'Unavailable',
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
}

class _ArchiveInfoCard extends StatelessWidget {
  const _ArchiveInfoCard({
    required this.channel,
    required this.listing,
  });

  final LiveChannel channel;
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

class _ArchiveRow extends StatelessWidget {
  const _ArchiveRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

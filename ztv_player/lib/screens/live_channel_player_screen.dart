import 'package:flutter/material.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/models/live_channel.dart';
import 'package:ztv_player/services/epg_service.dart';
import 'package:ztv_player/services/playback_service.dart';
import 'package:ztv_player/widgets/app_video_player.dart';
import 'package:ztv_player/widgets/media_detail_scaffold.dart';

class LiveChannelPlayerScreen extends StatefulWidget {
  LiveChannelPlayerScreen({
    super.key,
    required this.channel,
    this.playbackService = const PlaybackService(),
    EpgService? epgService,
  }) : epgService = epgService ?? EpgService();

  final LiveChannel channel;
  final PlaybackService playbackService;
  final EpgService epgService;

  @override
  State<LiveChannelPlayerScreen> createState() => _LiveChannelPlayerScreenState();
}

class _LiveChannelPlayerScreenState extends State<LiveChannelPlayerScreen> {
  EpgListing? _selectedArchiveListing;

  @override
  Widget build(BuildContext context) {
    final streamUrl = _selectedArchiveListing == null
        ? widget.playbackService.resolveLiveStreamUrl(widget.channel)
        : widget.playbackService.resolveArchiveStreamUrl(
            channel: widget.channel,
            listing: _selectedArchiveListing!,
          );
    final title = _selectedArchiveListing?.title.isNotEmpty == true
        ? _selectedArchiveListing!.title
        : widget.channel.name;

    return MediaDetailScaffold(
      title: title,
      player: AppVideoPlayer(
        streamUrl: streamUrl,
        placeholderImageUrl: widget.channel.logoUrl,
      ),
      content: _LiveChannelDetailContent(
        channel: widget.channel,
        streamAvailable: streamUrl != null && streamUrl.isNotEmpty,
        epgService: widget.epgService,
        selectedArchiveListing: _selectedArchiveListing,
        onArchiveSelected: (listing) {
          setState(() => _selectedArchiveListing = listing);
        },
        onLiveSelected: () {
          setState(() => _selectedArchiveListing = null);
        },
      ),
    );
  }
}

class _LiveChannelDetailContent extends StatelessWidget {
  const _LiveChannelDetailContent({
    required this.channel,
    required this.streamAvailable,
    required this.epgService,
    required this.selectedArchiveListing,
    required this.onArchiveSelected,
    required this.onLiveSelected,
  });

  final LiveChannel channel;
  final bool streamAvailable;
  final EpgService epgService;
  final EpgListing? selectedArchiveListing;
  final ValueChanged<EpgListing> onArchiveSelected;
  final VoidCallback onLiveSelected;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF23232D),
            child: const TabBar(
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: 'Live'),
                Tab(text: 'Archive'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                FutureBuilder<List<EpgListing>>(
                  future: epgService.getShortEpg(streamId: channel.id),
                  builder: (context, snapshot) {
                    final listings = snapshot.data ?? const <EpgListing>[];

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _NowPlayingTile(
                          channel: channel,
                          streamAvailable: streamAvailable,
                          selectedArchiveListing: selectedArchiveListing,
                          onPlayLive: onLiveSelected,
                        ),
                        const SizedBox(height: 16),
                        _InfoRow(
                          label: 'Channel',
                          value: channel.num?.toString() ?? '-',
                        ),
                        _InfoRow(
                          label: 'Category ID',
                          value: channel.categoryId,
                        ),
                        _InfoRow(label: 'Stream ID', value: channel.id),
                        _InfoRow(
                          label: 'Status',
                          value: streamAvailable
                              ? 'Ready for playback'
                              : 'No playable source found',
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'EPG',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (snapshot.hasError || listings.isEmpty)
                          const _EmptyEpgState()
                        else
                          ...listings.map(_EpgTile.new),
                      ],
                    );
                  },
                ),
                FutureBuilder<List<EpgListing>>(
                  future: epgService.getArchiveEpg(streamId: channel.id),
                  builder: (context, snapshot) {
                    final listings = snapshot.data ?? const <EpgListing>[];
                    final archiveListings = listings
                        .where((listing) => listing.hasArchive)
                        .toList();

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError || archiveListings.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Nema arhive za ovaj kanal.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: archiveListings.length,
                      itemBuilder: (context, index) {
                        final listing = archiveListings[index];
                        return _ArchiveTile(
                          listing: listing,
                          isSelected: selectedArchiveListing?.id == listing.id,
                          onTap: () => onArchiveSelected(listing),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpgTile extends StatelessWidget {
  const _EpgTile(this.listing);

  final EpgListing listing;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrent =
        !now.isBefore(listing.start) && now.isBefore(listing.end);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? Colors.amber : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  listing.title.isEmpty ? 'Untitled EPG item' : listing.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_formatTime(listing.start)} - ${_formatTime(listing.end)}',
                style: TextStyle(
                  color: isCurrent ? Colors.amber : Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (listing.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              listing.description,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
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

class _EmptyEpgState extends StatelessWidget {
  const _EmptyEpgState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Nema EPG za ovaj kanal.',
        style: TextStyle(color: Colors.white70, fontSize: 15),
      ),
    );
  }
}

class _ArchiveTile extends StatelessWidget {
  const _ArchiveTile({
    required this.listing,
    required this.isSelected,
    required this.onTap,
  });

  final EpgListing listing;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title.isEmpty
                        ? 'Untitled archive item'
                        : listing.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatTime(listing.start)} - ${_formatTime(listing.end)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.amber,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _NowPlayingTile extends StatelessWidget {
  const _NowPlayingTile({
    required this.channel,
    required this.streamAvailable,
    required this.selectedArchiveListing,
    required this.onPlayLive,
  });

  final LiveChannel channel;
  final bool streamAvailable;
  final EpgListing? selectedArchiveListing;
  final VoidCallback onPlayLive;

  @override
  Widget build(BuildContext context) {
    final isArchiveMode = selectedArchiveListing != null;

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
            isArchiveMode && selectedArchiveListing!.title.isNotEmpty
                ? selectedArchiveListing!.title
                : channel.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            !streamAvailable
                ? 'Playable source is missing for this channel.'
                : isArchiveMode
                    ? '${_formatTime(selectedArchiveListing!.start)} - ${_formatTime(selectedArchiveListing!.end)}'
                    : 'Playback is available. Use player controls for play and fullscreen.',
            style: const TextStyle(color: Colors.white70),
          ),
          if (isArchiveMode) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onPlayLive,
              icon: const Icon(Icons.live_tv_rounded),
              label: const Text('Back to live'),
            ),
          ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 92,
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

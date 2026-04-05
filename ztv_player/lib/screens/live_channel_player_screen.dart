import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:ztv_player/models/live_tv_channel.dart';
import 'package:ztv_player/models/epg_listing.dart';
import 'package:ztv_player/services/epg_service.dart';
import 'package:ztv_player/services/favorites_service.dart';
import 'package:ztv_player/services/playback_service.dart';
import 'package:ztv_player/widgets/enhanced_video_player.dart';
import 'package:ztv_player/widgets/media_detail_scaffold.dart';

class LiveChannelPlayerScreen extends StatefulWidget {
  LiveChannelPlayerScreen({
    super.key,
    required this.channel,
    this.playbackService = const PlaybackService(),
    EpgService? epgService,
  }) : epgService = epgService ?? EpgService();

  final LiveTvChannel channel;
  final PlaybackService playbackService;
  final EpgService epgService;

  @override
  State<LiveChannelPlayerScreen> createState() =>
      _LiveChannelPlayerScreenState();
}

class _LiveChannelPlayerScreenState extends State<LiveChannelPlayerScreen> {
  EpgListing? _selectedArchiveListing;
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
    // Ovdje biras sta player pusta: live stream ili selektovanu archive stavku.
    final streamUrl = _selectedArchiveListing == null
        ? widget.playbackService.resolveLiveStreamUrl(widget.channel)
        : widget.playbackService.resolveArchiveStreamUrl(
            channel: widget.channel,
            listing: _selectedArchiveListing!,
          );
    // Ovdje podesis naslov detail screena/AppBar-a.
    final title = _selectedArchiveListing?.title.isNotEmpty == true
        ? _selectedArchiveListing!.title
        : widget.channel.name;

    return MediaDetailScaffold(
      title: title,
      player: EnhancedVideoPlayer(
        streamUrl: streamUrl,
        placeholderImageUrl: widget.channel.logoUrl,
        isLiveStream: true,
        onControllerReady: (controller) => _playerController = controller,
        onFavoriteToggle: _toggleFavorite,
        isFavorite: _isFavoriteNotifier.value,
      ),
      content: _LiveChannelDetailContent(
        channel: widget.channel,
        epgService: widget.epgService,
      ),
    );
  }

  void _toggleFavorite() {
    final isFavorite = _favoritesService.toggleFavorite(
      FavoriteContentType.liveTv,
      widget.channel.id,
    );
    _isFavoriteNotifier.value = isFavorite;
  }
}

class _LiveChannelDetailContent extends StatelessWidget {
  static const _archiveTabEnabled = false;

  const _LiveChannelDetailContent({
    required this.channel,
    required this.epgService,
  });

  final LiveTvChannel channel;
  final EpgService epgService;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Ovdje podesis gornje tabove za content koji ide ispod playera.
          Container(
            color: const Color(0xFF23232D),
            child: TabBar(
              onTap: (index) {
                if (index == 1 && !_archiveTabEnabled) {
                  DefaultTabController.of(context).animateTo(0);
                }
              },
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Live'),
                Tab(
                  child: Text('Archive', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // LIVE TAB: ovdje slazes sve komponente koje zelis ispod playera za live sadrzaj.
                FutureBuilder<List<EpgListing>>(
                  future: epgService.getShortEpg(streamId: channel.id),
                  builder: (context, snapshot) {
                    final listings = snapshot.data ?? const <EpgListing>[];

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Ovdje dodajes ili mijenjas pojedinacne content komponente u Live tabu.
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
                          // Ovdje se renderuje lista EPG kartica.
                          ...listings.map(_EpgTile.new),
                      ],
                    );
                  },
                ),
                // ARCHIVE TAB: privremeno disabled dok ne zavrsimo archive flow.
                const _ArchiveDisabledState(),
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
    final isCurrent = !now.isBefore(listing.start) && now.isBefore(listing.end);

    // Ovdje podesis izgled jedne EPG stavke u Live tabu.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B35),
        // borderRadius: BorderRadius.circular(14),
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

class _ArchiveDisabledState extends StatelessWidget {
  const _ArchiveDisabledState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Archive je privremeno onemogucen.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

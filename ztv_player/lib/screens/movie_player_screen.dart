import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:ztv_player/helpers/media_format.dart';
import 'package:ztv_player/models/vod_details.dart';
import 'package:ztv_player/models/vod_movie.dart';
import 'package:ztv_player/services/favorites_service.dart';
import 'package:ztv_player/services/movie_service.dart';
import 'package:ztv_player/services/playback_service.dart';
import 'package:ztv_player/widgets/enhanced_video_player.dart';
import 'package:ztv_player/widgets/media_detail_scaffold.dart';

class MoviePlayerScreen extends StatefulWidget {
  MoviePlayerScreen({
    super.key,
    required this.movie,
    PlaybackService? playbackService,
    MovieService? movieService,
  }) : playbackService = playbackService ?? const PlaybackService(),
       movieService = movieService ?? MovieService();

  final VodMovie movie;
  final PlaybackService playbackService;
  final MovieService movieService;

  @override
  State<MoviePlayerScreen> createState() => _MoviePlayerScreenState();
}

class _MoviePlayerScreenState extends State<MoviePlayerScreen> {
  bool _hasStartedPlayback = false;
  late final ValueNotifier<bool> _isPlayingNotifier;
  late final ValueNotifier<bool> _isFavoriteNotifier;
  BetterPlayerController? _playerController;
  late final Future<VodDetails> _detailsFuture;
  final FavoritesService _favoritesService = const FavoritesService();

  @override
  void initState() {
    super.initState();
    final isFavorite = _favoritesService.isFavorite(
      FavoriteContentType.movie,
      widget.movie.id,
    );
    _isFavoriteNotifier = ValueNotifier(isFavorite);
    _isPlayingNotifier = ValueNotifier(false);
    _detailsFuture = widget.movieService.getMovieDetails(widget.movie.id);
  }

  @override
  void dispose() {
    _isPlayingNotifier.dispose();
    _isFavoriteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamUrl = widget.playbackService.resolveMovieStreamUrl(
      widget.movie,
      extension: widget.movie.containerExtension ?? 'mp4',
    );

    return MediaDetailScaffold(
      title: widget.movie.name,
      player: EnhancedVideoPlayer(
        streamUrl: _hasStartedPlayback ? streamUrl : null,
        placeholderImageUrl: widget.movie.logoUrl,
        autoInitialize: _hasStartedPlayback,
        isLiveStream: false,
        onControllerReady: (controller) => _playerController = controller,
        idleTitle: 'Tap play when you want to start this movie.',
        idleActionLabel: 'Play movie',
        onIdleAction: () {
          setState(() => _hasStartedPlayback = true);
        },
        onFavoriteToggle: _toggleFavorite,
        isFavorite: _isFavoriteNotifier.value,
      ),
      content: FutureBuilder<VodDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _MovieFallbackDetails(movie: widget.movie);
          }

          final details = snapshot.data;
          if (details == null) {
            return _MovieFallbackDetails(movie: widget.movie);
          }

          return _MovieDetailsContent(movie: widget.movie, details: details);
        },
      ),
    );
  }

  void _togglePlayback() {
    if (!_hasStartedPlayback) {
      setState(() => _hasStartedPlayback = true);
      return;
    }

    final controller = _playerController;
    if (controller == null) {
      return;
    }

    if (_isPlayingNotifier.value) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _toggleFavorite() {
    final isFavorite = _favoritesService.toggleFavorite(
      FavoriteContentType.movie,
      widget.movie.id,
    );
    _isFavoriteNotifier.value = isFavorite;
  }
}

class _MovieDetailsContent extends StatelessWidget {
  const _MovieDetailsContent({required this.movie, required this.details});

  final VodMovie movie;
  final VodDetails details;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MovieHeaderCard(movie: movie, details: details),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MovieMetaChip(label: 'Genre', value: details.genre),
            _MovieMetaChip(
              label: 'Rating',
              value: formatNullableRating(details.rating ?? movie.rating),
            ),
            _MovieMetaChip(
              label: 'Release',
              value: details.releaseDate ?? movie.year,
            ),
            _MovieMetaChip(label: 'Duration', value: details.duration),
            _MovieMetaChip(label: 'Country', value: details.country),
          ],
        ),
        const SizedBox(height: 18),
        _MovieInfoSection(
          title: 'Overview',
          value: details.description ?? movie.plot,
        ),
        _MovieInfoSection(title: 'Director', value: details.director),
        _MovieInfoSection(title: 'Cast', value: details.cast),
      ],
    );
  }
}

class _MovieHeaderCard extends StatelessWidget {
  const _MovieHeaderCard({required this.movie, required this.details});

  final VodMovie movie;
  final VodDetails details;

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
            details.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (details.originalName != null &&
              details.originalName!.isNotEmpty &&
              details.originalName != details.name) ...[
            const SizedBox(height: 6),
            Text(
              details.originalName!,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}

class _MovieFallbackDetails extends StatelessWidget {
  const _MovieFallbackDetails({required this.movie});

  final VodMovie movie;

  @override
  Widget build(BuildContext context) {
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
                movie.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (movie.plot != null && movie.plot!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  movie.plot!,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MovieMetaChip(
              label: 'Rating',
              value: formatNullableRating(movie.rating),
            ),
            _MovieMetaChip(label: 'Year', value: movie.year),
            _MovieMetaChip(
              label: 'Format',
              value: movie.containerExtension?.toUpperCase(),
            ),
          ],
        ),
      ],
    );
  }
}

class _MovieMetaChip extends StatelessWidget {
  const _MovieMetaChip({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieInfoSection extends StatelessWidget {
  const _MovieInfoSection({required this.title, required this.value});

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value!,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}


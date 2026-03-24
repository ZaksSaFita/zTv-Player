import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({
    super.key,
    required this.streamUrl,
    this.placeholderImageUrl,
  });

  final String? streamUrl;
  final String? placeholderImageUrl;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  Player? _player;
  VideoController? _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _disposeController();
      _initializePlayer();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final streamUrl = widget.streamUrl;
    if (streamUrl == null || streamUrl.isEmpty) {
      setState(() => _errorMessage = 'Playable stream URL is missing.');
      return;
    }

    try {
      final player = Player();
      final controller = VideoController(player);

      await player.open(Media(streamUrl));

      if (!mounted) {
        await player.dispose();
        return;
      }

      setState(() {
        _errorMessage = null;
        _player = player;
        _controller = controller;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Stream could not be loaded.';
        _player = null;
        _controller = null;
      });
    }
  }

  void _disposeController() {
    _player?.dispose();
    _player = null;
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF17171F)),
        child: _controller == null || _player == null
            ? _PlayerFallback(
                placeholderImageUrl: widget.placeholderImageUrl,
                errorMessage: _errorMessage,
              )
            : MaterialVideoControlsTheme(
                normal: const MaterialVideoControlsThemeData(
                  seekBarMargin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  buttonBarButtonSize: 24,
                  topButtonBarMargin: EdgeInsets.zero,
                ),
                fullscreen: const MaterialVideoControlsThemeData(
                  seekBarMargin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  buttonBarButtonSize: 24,
                ),
                child: Video(
                  controller: _controller!,
                  controls: MaterialVideoControls,
                  fill: Colors.black,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}

class _PlayerFallback extends StatelessWidget {
  const _PlayerFallback({
    required this.placeholderImageUrl,
    this.errorMessage,
  });

  final String? placeholderImageUrl;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final imageUrl = placeholderImageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const _FallbackSurface(showIcon: true),
          ),
          const ColoredBox(color: Colors.black38),
          const Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 68,
            ),
          ),
          if (errorMessage != null)
            _ErrorSurface(message: errorMessage!),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const _FallbackSurface(showIcon: true),
        if (errorMessage != null)
          _ErrorSurface(message: errorMessage!),
      ],
    );
  }
}

class _FallbackSurface extends StatelessWidget {
  const _FallbackSurface({required this.showIcon});

  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF23232D),
      alignment: Alignment.center,
      child: showIcon
          ? const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white70,
              size: 68,
            )
          : null,
    );
  }
}

class _ErrorSurface extends StatelessWidget {
  const _ErrorSurface({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: Colors.black87,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

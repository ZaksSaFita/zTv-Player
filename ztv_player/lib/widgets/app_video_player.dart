import 'package:better_player_plus/better_player_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
  BetterPlayerController? _controller;
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
    final streamUrl = widget.streamUrl?.trim();
    if (streamUrl == null || streamUrl.isEmpty) {
      setState(() => _errorMessage = 'Playable stream URL is missing.');
      return;
    }

    try {
      debugPrint('BetterPlayer opening: $streamUrl');

      final configuration = BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        allowedScreenSleep: false,
        handleLifecycle: true,
        fit: BoxFit.cover,
        aspectRatio: 16 / 9,
        placeholderOnTop: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableQualities: false,
          enableSubtitles: false,
          enableAudioTracks: false,
          enableOverflowMenu: false,
          enableSkips: false,
          enablePlaybackSpeed: false,
          controlBarColor: Colors.black54,
          iconsColor: Colors.white,
          progressBarPlayedColor: Colors.orange,
          progressBarHandleColor: Colors.orange,
          progressBarBufferedColor: Colors.white38,
          progressBarBackgroundColor: Colors.white12,
        ),
      );

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        streamUrl,
        liveStream: true,
        videoFormat: _detectFormat(streamUrl),
        notificationConfiguration: const BetterPlayerNotificationConfiguration(
          showNotification: false,
        ),
      );

      final controller = BetterPlayerController(configuration);
      controller.addEventsListener(_handlePlayerEvent);
      await controller.setupDataSource(dataSource);

      if (!mounted) {
        controller.dispose(forceDispose: true);
        return;
      }

      setState(() {
        _errorMessage = null;
        _controller = controller;
      });
    } catch (error, stackTrace) {
      debugPrint('BetterPlayer failed for: $streamUrl');
      debugPrint('BetterPlayer error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Stream could not be loaded.\n$error';
        _controller = null;
      });
    }
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (!mounted) {
      return;
    }

    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      final message = event.parameters?['exception']?.toString() ??
          'Unknown playback error.';
      debugPrint('BetterPlayer exception: $message');
      setState(() => _errorMessage = message);
    }
  }

  BetterPlayerVideoFormat? _detectFormat(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8')) {
      return BetterPlayerVideoFormat.hls;
    }
    if (lower.contains('.mpd')) {
      return BetterPlayerVideoFormat.dash;
    }
    return null;
  }

  void _disposeController() {
    final controller = _controller;
    if (controller != null) {
      controller.removeEventsListener(_handlePlayerEvent);
      controller.dispose(forceDispose: true);
    }
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF17171F)),
        child: _controller == null
            ? _PlayerFallback(
                placeholderImageUrl: widget.placeholderImageUrl,
                errorMessage: _errorMessage,
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  BetterPlayer(controller: _controller!),
                  if (_errorMessage != null)
                    _ErrorSurface(message: _errorMessage!),
                ],
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
          if (errorMessage != null) _ErrorSurface(message: errorMessage!),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const _FallbackSurface(showIcon: true),
        if (errorMessage != null) _ErrorSurface(message: errorMessage!),
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
